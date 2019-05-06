class Cron < Kiloton::Schedule
  every 1.day, "CleanupJob"
end
