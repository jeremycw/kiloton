require "http/server"
require "redis"
require "uuid"
require "cannon"
require "io/memory"
require "schedule"
require "./frontend/*"
require "./common/*"

tmp = File.tempfile("worker")
IO.copy(Kiloton::Vfs.get("kiloton-worker"), tmp)
File.chmod(tmp.path, 0o777)
tmp.close

workers = 4
workers.times do
  Process.fork do
    Process.exec(tmp.path)
  end
end

redis = Redis::PooledClient.new(url: "redis://127.0.0.1:6379/0")
rpc = Kiloton::RpcService.new(redis)
http = Kiloton::HttpFrontend.new(rpc, 8080)
http.listen
