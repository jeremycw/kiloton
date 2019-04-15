require "redis"
require "json"
require "./router"
require "./procedure"
require "../common/request_json"
require "../common/response_json"

class HttpProcedure < Procedure
  def initialize(@data : JSON::Any, @redis : Redis::PooledClient, @router : Router)
  end

  def respond(response)
    str = ResponseJson.new(response).to_json
    @redis.pipelined do |pipe|
      pipe.lpush(@data["response"], str)
      pipe.expire(@data["response"], 30)
    end
  end

  def perform(args)
    request = RequestJson.from_json(args[0].to_json).to_request
    response = @router.call(request)
    if !response.nil?
      respond(response)
    else
      #404
    end
  end
end

