require "http/server"
require "redis"
require "uuid"
require "json"
require "./frontend/*"
require "./common/*"


http = HttpFrontend.new(8080, "redis://127.0.0.1:6379/0")
http.listen
