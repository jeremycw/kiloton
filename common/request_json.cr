require "json"
require "http/server"

class RequestJson
  JSON.mapping({
    headers: Hash(String, String),
    body: { type: String, nilable: true },
    resource: String,
    method: String
  })

  def to_request
    http_headers = HTTP::Headers.new
    headers.each do |k,v|
      http_headers[k] = v
    end
    HTTP::Request.new(method, resource, http_headers, body)
  end
end
