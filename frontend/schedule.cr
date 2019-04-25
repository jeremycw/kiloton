module Kiloton
  class Schedule
    macro every(*args)
      {% job = args.pop %}
      ::Schedule.every(*args) do
      end
    end
  end
end
