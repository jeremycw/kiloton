class Routes < Kiloton::Router
  get "/", "HomeController#index"
  get "/hello/:name", "HomeController#hello_world"
end
