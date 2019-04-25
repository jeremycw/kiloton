class Routes < Kiloton::Router
  get "/", "HomeController#index"
end
