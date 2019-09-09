require "redis"
require "query-builder"
require "http/server"
require "mysql"
require "cannon"
require "schedule"
require "uuid"
require "./common/**"
require "./backend/**"
require "./app/routes"
require "./app/jobs/**"
require "./app/controllers/**"

{% for klass in Kiloton::Job.all_subclasses %}
  class {{ klass }} < Kiloton::Job
    include Cannon::Auto

    def perform_later
      io = IO::Memory.new
      Cannon.encode io, self
      rpc_id = UUID.random
      rpc_hex = rpc_id.hexstring
      rpc = Kiloton::Rpc.new("job", "", "{{ klass }}")
      key = "kiloton:rpc:request:#{rpc_hex}"
      arg_key = "kiloton:rpc:arg:#{rpc_hex}"
      Kiloton::Job.redis.pipelined do |pipe|
        io = IO::Memory.new
        Cannon.encode(io, rpc)
        pipe.set(key, io.to_s)
        io = IO::Memory.new
        Cannon.encode(io, self)
        pipe.set(arg_key, io.to_s)
        pipe.publish("kiloton:worker", String.new(rpc_id.to_unsafe.to_slice(16)))
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
worker.register("job", Proc(String, Kiloton::Rpc, Kiloton::Procedure).new { |data, job| Kiloton::JobProcedure.new(data, job) })
worker.handle_orphans
worker.listen
Kiloton::Database.connection.close
