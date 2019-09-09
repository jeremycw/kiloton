require "uuid"

class Kiloton::HttpCaller
  def initialize(@redis : Redis::PooledClient)
  end

  def call(request)
    body = nil
    io = request.body 
    if !io.nil?
      body = io.gets_to_end
    end
    raw_uuid = String.new(UUID.random.to_unsafe.to_slice(16))
    headers = Array(Tuple(String, String)).new
    request.headers.each do |k,v|
      headers << { k, v[0] }
    end
    request = Request.new(headers, body, request.resource, request.method)
    response_key = "kilo:res:#{raw_uuid}"
    rpc = Rpc.new("http", response_key, "Request")
    key = "kilo:req:#{raw_uuid}"
    arg_key = "kilo:arg:#{raw_uuid}"
    @redis.pipelined do |pipe|
      io = IO::Memory.new
      Cannon.encode(io, rpc)
      pipe.set(key, io.to_s)
      io = IO::Memory.new
      Cannon.encode(io, request)
      pipe.set(arg_key, io.to_s)
      pipe.publish("kiloton:worker", raw_uuid)
    end
    response = @redis.blpop [response_key], 20
    @redis.del response_key
    if !response.nil? && response.size > 1
      obj = response[1]
      if obj.is_a?(String)
        io = IO::Memory.new(obj)
        return Cannon.decode(io, Response)
      else
        raise "Internal Server Error"
      end
    else
      raise "Timeout"
    end
  end
end
