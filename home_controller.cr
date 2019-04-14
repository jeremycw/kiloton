class HomeController
  private getter request, params

  def initialize(@request : HTTP::Request, @params : HTTP::Params)
  end

  def index
    puts "Hello, World!"
  end
end
