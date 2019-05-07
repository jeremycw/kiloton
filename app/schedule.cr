class Cron < Kiloton::Schedule
  schedule do
    every 1.second, ScheduledJob
  end
end
