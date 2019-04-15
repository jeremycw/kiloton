class HomeController < Kiloton::Controller
  def index
    max_age = database.scalar "select count(*) from matchmakers"
    HTTP::Client::Response.new(200, max_age.to_s)
  end
end
