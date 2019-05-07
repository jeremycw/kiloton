module Kiloton
  class Schedule
    macro schedule(&blk)
      def create_schedule
        {{ blk.body }}
      end
    end

    macro every(*args)
      {% job = args.last %}
      {% new_args = args.reject { |a| a.id == job.id } %}
      ::Schedule.every({{*new_args}}) do
        {{ job }}.new.perform_later
      end
    end
  end
end
