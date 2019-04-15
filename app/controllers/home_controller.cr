class HomeController < Kiloton::Controller
  def index
    max_age = database.scalar "select count(*) from matchmakers"
    query.table("matchmakers").get_all do |rs|
      puts rs.column_name(0)
    end
    HTTP::Client::Response.new(200, max_age.to_s)
  end
end
