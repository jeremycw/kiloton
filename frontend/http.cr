class Kiloton::HttpFrontend
  def initialize(@rpc : RpcService, @port : Int32)
  end

  def listen
    server = HTTP::Server.new do |context|
      res = @rpc.http.call(context.request)
      res.output(context.response)
    end
    server.bind_tcp @port
    server.listen
  end
end
