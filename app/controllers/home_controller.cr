class HomeController
  private getter request, params

  def initialize(@request : HTTP::Request, @params : HTTP::Params)
  end

  def index
    HTTP::Client::Response.new(200, "Hello, World!")
  end
end
