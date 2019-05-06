module Kiloton
  class Schedule
    macro every(*args)
      {% job = args.last %}
      {% new_args = args.reject { |a| a.id == job.id } %}
      ::Schedule.every({{*new_args}}) do

      end
    end
  end
end
