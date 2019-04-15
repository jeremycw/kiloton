require "json"

class ResponseJson
  JSON.mapping({
    headers: Hash(String, String),
    body: { type: String, nilable: true },
    status_code: Int32
  })

  def initialize(response : HTTP::Client::Response)
    @status_code = response.status_code
    @body = response.body
    @headers = {} of String => String
    response.headers.each do |k,v|
      headers[k] = v[0]
    end
  end

  def output(response)
    headers.each do |k,v|
      response.headers[k] = v
    end
    response.status_code = status_code
    response.print body
  end
end

