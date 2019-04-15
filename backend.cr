require "redis"
require "json"
require "http/server"
require "mysql"
require "./backend/*"
require "./common/*"
require "./app/**"

redis_url = "redis://127.0.0.1:6379/0"
worker = Worker.new(redis_url)
redis = Redis::PooledClient.new(url: redis_url)
router = Routes.new
worker.register("http", Proc(JSON::Any, Procedure).new { |data| HttpProcedure.new(data, redis, router) })
worker.handle_orphans
worker.listen
Kiloton::Controller.database.close
