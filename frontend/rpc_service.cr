class Kiloton::RpcService
  property http : HttpCaller

  def initialize(@redis : Redis::PooledClient)
    @http = HttpCaller.new(@redis)
  end
end
