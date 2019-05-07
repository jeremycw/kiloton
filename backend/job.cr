class Kiloton::Job
  @@redis : Redis::PooledClient?

  def self.redis=(redis)
    @@redis = redis
  end

  def self.redis
    @@redis.not_nil!
  end

  def query
    Controller::ConcreteBuilder.new(database)
  end

  def database
    Database.connection
  end
end
