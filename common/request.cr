require "http/server"

class Kiloton::Request
  include Cannon::Auto

  property headers : Array(Tuple(String, String))
  property body : String?
  property resource : String
  property method : String

  def initialize(@headers, @body, @resource, @method)
  end

  def to_request
    http_headers = HTTP::Headers.new
    headers.each do |k,v|
      http_headers[k] = v
    end
    HTTP::Request.new(method, resource, http_headers, body)
  end
end
