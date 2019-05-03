class Kiloton::Response
  include Cannon::Auto

  property status_code : Int32
  property headers : Array(Tuple(String, String))
  property body : String?

  def initialize(response : HTTP::Client::Response)
    @status_code = response.status_code
    @body = response.body
    @headers = [] of { String, String }
    response.headers.each do |k,v|
      headers << { k, v[0] }
    end
  end

  def initialize(@status_code, @headers, @body)
  end

  def output(response)
    headers.each do |k,v|
      response.headers[k] = v
    end
    response.status_code = status_code
    response.print body
  end
end

