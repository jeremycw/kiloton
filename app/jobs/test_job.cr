class TestJob < Kiloton::Job
  def initialize(@msg : String)
  end

  def perform
    puts @msg
  end
end
