require "./router"

class Routes < Router
  get "/", "HomeController#index"
end
