class ScheduledJob < Kiloton::Job
  def perform
    puts "Scheduled work!"
  end
end
