class HomeController < Kiloton::Controller
  def index
    res = "{ \"customers\":["
    query.table("customers").select("id, email").is_not_null("email").limit(100).get_all do |rs|
      sep = ""
      rs.each do
        res += "#{sep}{ \"id\": #{rs.read(Int32)}, \"email\": \"#{rs.read(String?)}\" }"
        sep = ","
      end
      res += "]}"
    end
    TestJob.new("Wtf?!").perform_later
    HTTP::Client::Response.new(200, res)
  end

  def hello_world
    HTTP::Client::Response.new(200, "Hello, #{params["name"]}!")
  end
end
