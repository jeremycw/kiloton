class Kiloton::Worker
  def initialize(@url : String)
    @redis = Redis::PooledClient.new(url: @url)
    @procedures = {} of String => Proc(String, String, Procedure)
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

  def handle(key)
    future = Redis::Future.new
    arg_future = Redis::Future.new
    return unless key.is_a?(String)
    tmp = key.split(":")
    id = tmp.pop
    arg_key = "kiloton:rpc:arg:#{id}"
    @redis.multi do |client|
      future = client.get(key)
      arg_future = client.get(arg_key)
      client.del(key)
      client.del(arg_key)
    end
    str = future.value
    arg = arg_future.value
    if str.is_a?(String)
      job = Cannon.decode(IO::Memory.new(str), Job)
      @procedures[job.procedure].call(arg.is_a?(String) ? arg : "", job.response_key).perform
    end
  end
end
