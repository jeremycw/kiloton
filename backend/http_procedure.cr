require "./procedure"

class HttpProcedure < Procedure
  @request : Request

  def initialize(@data : String, @response_key : String, @redis : Redis::PooledClient, @router : Kiloton::Router)
    io = IO::Memory.new(@data)
    @request = Cannon.decode(io, Request)
  end

  def respond(response)
    io = IO::Memory.new
    Cannon.encode(io, Response.new(response))
    @redis.pipelined do |pipe|
      pipe.lpush(@response_key, io.to_s)
      pipe.expire(@response_key, 30)
    end
  end

  def perform
    request = @request.to_request
    response = @router.call(request)
    if !response.nil?
      respond(response)
    else
      #404
    end
  end
end

