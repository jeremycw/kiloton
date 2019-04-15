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
