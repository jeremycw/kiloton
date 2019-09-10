module Kiloton::PerformLater
  def self.send(klass, obj)
    io = IO::Memory.new
    Cannon.encode io, obj
    raw_uuid = String.new(UUID.random.to_unsafe.to_slice(16))
    rpc = Kiloton::Rpc.new("job", "", klass)
    key = "kilo:req:#{raw_uuid}"
    arg_key = "kilo:arg:#{raw_uuid}"
    Kiloton::Job.redis.pipelined do |pipe|
      io = IO::Memory.new
      Cannon.encode(io, rpc)
      pipe.set(key, io.to_s)
      io = IO::Memory.new
      Cannon.encode(io, obj)
      pipe.set(arg_key, io.to_s)
      pipe.publish("kiloton:worker", raw_uuid)
    end
  end
end
