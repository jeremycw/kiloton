class Job
  include Cannon::Auto

  property procedure : String
  property response_key : String
  property arg_type : String

  def initialize(@procedure, @response_key, @arg_type)
  end
end
