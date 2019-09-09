class Kiloton::Worker
  def initialize(@url : String)
    @redis = Redis::PooledClient.new(url: @url)
    @procedures = {} of String => Proc(String, Rpc, Procedure)
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
        spawn { handle(message) }
      end
    end
  end

  def handle(raw_uuid)
    future = Redis::Future.new
    arg_future = Redis::Future.new
    return unless raw_uuid.is_a?(String)
    uuid = UUID.new(raw_uuid.to_unsafe.to_slice(16)).hexstring
    key = "kiloton:rpc:request:#{uuid}"
    arg_key = "kiloton:rpc:arg:#{uuid}"
    @redis.multi do |client|
      future = client.get(key)
      arg_future = client.get(arg_key)
      client.del(key)
      client.del(arg_key)
    end
    str = future.value
    arg = arg_future.value
    if str.is_a?(String)
      rpc = Cannon.decode(IO::Memory.new(str), Rpc)
      @procedures[rpc.procedure].call(arg.is_a?(String) ? arg : "", rpc).perform
    end
  end
end
