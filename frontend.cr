require "http/server"
require "redis"
require "uuid"
require "cannon"
require "schedule"
require "./common/**"
require "./frontend/**"
require "./app/schedule"
require "./app/jobs/**"

module Kiloton
  @@master : Bool = false

  def self.master=(master)
    @@master = master
  end

  def self.master
    @@master
  end
end

{% for klass in Kiloton::Job.all_subclasses %}
  class {{ klass }} < Kiloton::Job
    include Cannon::Auto

    def perform_later
      io = IO::Memory.new
      Cannon.encode io, self
      rpc_id = UUID.random.hexstring
      rpc = Kiloton::Rpc.new("job", "", "{{ klass }}")
      key = "kiloton:rpc:request:#{rpc_id}"
      arg_key = "kiloton:rpc:arg:#{rpc_id}"
      Kiloton::Job.redis.pipelined do |pipe|
        io = IO::Memory.new
        Cannon.encode(io, rpc)
        pipe.set(key, io.to_s)
        io = IO::Memory.new
        Cannon.encode(io, self)
        pipe.set(arg_key, io.to_s)
        pipe.publish("kiloton:worker", key)
      end
    end
  end
{% end %}

tmp = File.tempfile("worker")
IO.copy(Kiloton::Vfs.get("kiloton-worker"), tmp)
File.chmod(tmp.path, 0o777)
tmp.close

workers = 4
workers.times do
  Process.fork do
    Process.exec(tmp.path)
  end
end

lua = <<-LUA
if redis.call('exists', KEYS[1]) == 0 then
  redis.call('set', KEYS[1], 1)
  redis.call('expire', KEYS[1], 6)
  return {1, KEYS[1], 'OK'}
else
  return {0, KEYS[1], 'OK'}
end
LUA

redis = Redis::PooledClient.new(url: "redis://127.0.0.1:6379/0")
spawn do
  loop do
    future = Redis::Future.new
    redis.multi do |client|
      client.del("kiloton:master") if Kiloton.master
      future = client.eval(lua, ["kiloton:master"])
    end
    master = future.value
    Kiloton.master = master[0] == 1 if master.is_a?(Array(Redis::RedisValue))
    sleep 5.seconds
  end
end
Kiloton::Job.redis = redis
rpc = Kiloton::RpcService.new(redis)
http = Kiloton::HttpFrontend.new(rpc, 8080)
schedule = Cron.new
schedule.create_schedule
http.listen
