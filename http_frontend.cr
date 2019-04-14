require "http/server"
require "redis"
require "uuid"
require "json"

class HttpFrontend
  def initialize(@port : Int32, @url : String)
    @redis = Redis::PooledClient.new(url: @url)
  end

  def listen
    server = HTTP::Server.new do |context|
      body = context.request.body
      rpc_id = UUID.random.hexstring
      response_key = "kiloton:rpc:response:#{rpc_id}"
      rpc = JSON.build do |json|
        json.object do
          json.field "procedure", "http"
          json.field "response", response_key
          json.field "args" do
            json.array do
              json.object do
                if !body.nil?
                  json.field "body", body.gets_to_end
                end
                json.field "headers" do
                  json.object do
                    context.request.headers.each do |k,v|
                      json.field k, v[0]
                    end
                  end
                end
                json.field "method", context.request.method
                json.field "resource", context.request.resource
              end
            end
          end
        end
      end
      key = "kiloton:rpc:request:#{rpc_id}"
      @redis.pipelined do |pipe|
        pipe.set(key, rpc)
        pipe.publish("kiloton:worker", key)
      end
      response = @redis.blpop [response_key], 20
      @redis.del response_key
      if !response.nil? && response.size > 1
        context.response.print response[1]
      else
        #502
      end
    end
    server.bind_tcp @port
    server.listen
  end
end

http = HttpFrontend.new(8080, "redis://127.0.0.1:6379/0")
http.listen
