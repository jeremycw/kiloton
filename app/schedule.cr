class Cron < Kiloton::Schedule
  schedule do
    every 1.minute, ScheduledJob
  end
end
