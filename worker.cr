require "redis"
require "json"
require "http/server"
require "./routes"
require "./home_controller"

class Worker
  def initialize(@url : String)
    @redis = Redis::PooledClient.new(url: @url)
    @procedures = {} of String => Proc(JSON::Any, Procedure)
  end

  def register(name, procedure)
    @procedures[name] = procedure
  end

  def handle_orphans
    @redis.keys("kiloton:rpc:request:*").each do |key|
      handle(key)
    end
  end

  def listen
    redis = Redis.new(url: @url)
    redis.subscribe("kiloton:worker") do |on|
      on.message do |channel, message|
        handle(message)
      end
    end
  end

  def handle(key)
    future = Redis::Future.new
    @redis.multi do |client|
      future = client.get(key)
      client.del(key)
    end
    str = future.value
    if str.is_a?(String)
      json = JSON.parse(str)
      @procedures[json["procedure"]].call(json).perform(json["args"])
    end
  end
end

abstract class Procedure
  abstract def perform(args)
end

class HttpProcedure < Procedure
  def initialize(@data : JSON::Any, @redis : Redis::PooledClient, @router : Router)
  end

  def respond(response)
    @redis.pipelined do |pipe|
      pipe.lpush(@data["response"], response)
      pipe.expire(@data["response"], 30)
    end
  end

  def perform(args)
    request = RequestJson.from_json(args[0].to_json).to_request
    respond(@router.call(request))
  end
end

class RequestJson
  JSON.mapping({
    headers: Hash(String, String),
    body: { type: String, nilable: true },
    resource: String,
    method: String
  })

  def to_request
    http_headers = HTTP::Headers.new
    headers.each do |k,v|
      http_headers[k] = v
    end
    HTTP::Request.new(method, resource, http_headers, body)
  end
end

redis_url = "redis://127.0.0.1:6379/0"
worker = Worker.new(redis_url)
redis = Redis::PooledClient.new(url: redis_url)
router = Routes.new
worker.register("http", Proc(JSON::Any, Procedure).new { |data| HttpProcedure.new(data, redis, router) })
worker.handle_orphans
worker.listen
