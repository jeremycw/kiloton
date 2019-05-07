class Kiloton::JobProcedure < Kiloton::Procedure
  def initialize(@arg : String, @rpc : Rpc)
  end


  def perform
    {% begin %}
      io = IO::Memory.new(@arg)
      case @rpc.arg_type
      {% for klass in Kiloton::Job.all_subclasses %}
      when "{{ klass }}"
        job = Cannon.decode io, {{ klass }}
        job.perform
      {% end %}
      end
    {% end %}
  end
end

