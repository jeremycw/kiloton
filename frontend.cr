require "http/server"
require "redis"
require "uuid"
require "cannon"
require "io/memory"
require "./frontend/*"
require "./common/*"

tmp = File.tempfile("worker")
IO.copy(Vfs.get("kiloton-worker"), tmp)
File.chmod(tmp.path, 0o777)
tmp.close

workers = 4
workers.times do
  Process.fork do
    Process.exec(tmp.path)
  end
end

http = HttpFrontend.new(8080, "redis://127.0.0.1:6379/0")
http.listen
