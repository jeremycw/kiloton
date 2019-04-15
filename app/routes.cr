require "./controllers/home_controller"
require "../backend/router"

class Routes < Router
  get "/", "HomeController#index"
end
