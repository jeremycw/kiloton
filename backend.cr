require "redis"
require "query-builder"
require "http/server"
require "mysql"
require "cannon"
require "schedule"
require "uuid"
require "./backend/*"
require "./common/*"
require "./frontend/schedule"
require "./app/**"

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

redis_url = "redis://127.0.0.1:6379/0"
worker = Kiloton::Worker.new(redis_url)
redis = Redis::PooledClient.new(url: redis_url)
Kiloton::Job.redis = redis
router = Routes.new
worker.register("http", Proc(String, Kiloton::Rpc, Kiloton::Procedure).new { |data, job| Kiloton::HttpProcedure.new(data, job, redis, router) })
worker.handle_orphans
worker.listen
Kiloton::Database.connection.close
