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
      Kiloton::PerformLater.send("{{ klass }}", self)
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
