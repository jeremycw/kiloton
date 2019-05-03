require "redis"
require "json"
require "http/server"
require "mysql"
require "cannon"
require "io/memory"
require "./backend/*"
require "./common/*"
require "./app/**"

redis_url = "redis://127.0.0.1:6379/0"
worker = Worker.new(redis_url)
redis = Redis::PooledClient.new(url: redis_url)
router = Routes.new
worker.register("http", Proc(String, String, Procedure).new { |data, response_key| HttpProcedure.new(data, response_key, redis, router) })
worker.handle_orphans
worker.listen
Kiloton::Controller.database.close
