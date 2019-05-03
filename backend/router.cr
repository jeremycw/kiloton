module Kiloton
  abstract class Router
    abstract def call(request)

    macro inherited
      {% methods = %i(GET POST PUT PATCH DELETE) %}
      ROUTES = {} of String => Array(Kiloton::Route)

      def self.routes
        ROUTES
      end

      def call(request)
        path = request.path || "/"
        return unless path.starts_with?(@mountpoint)
        path = path[@mountpoint.size..-1]
        (0..path.size).reverse_each do |i|
          path_slice = path[0...i]
          next unless routes = self.class.routes[path_slice]?
          routes.each do |route|
            next unless match = route.match(request.method, path)
            return route.call_action(request, match)
          end
        end
      end

      macro group(prefix)
        Kiloton::Route.prefixed(\{{prefix}}) { \{{yield}} }
      end

      {% for method in methods %}
        macro {{method.downcase.id}}(pattern, action)
          \{% action_error = "action must be either a string of the form `Controller#action' or a Proc" %}
          \{% if action.is_a?(StringLiteral) %}
            \{% controller = action.split("#")[0] %}
            \{% action = action.split("#")[1] %}
            \{% raise(action_error) unless controller && action %}
            \{% action = "Proc(HTTP::Request, HTTP::Params, HTTP::Client::Response).new { |request, params| controller = #{controller.id}.new(request, params); controller.#{action.id} }" %}
          \{% elsif !action.is_a?(ProcLiteral) %}
             \{% raise(action_error) %}
          \{% end %}
          \{% static_part = %["\#{Kiloton::Route.prefix}#{pattern.id}".gsub(/(\\:|\\(|\\/$).*/, "")] %}
          ROUTES[\{{static_part.id}}] ||= [] of Kiloton::Route
          ROUTES[\{{static_part.id}}] << Kiloton::Route.new({{method.id.stringify}}, \{{pattern}}, \{{action.id}})
        end

        macro {{method.downcase.id}}(pattern)
        \{% action = "Proc(HTTP::Request, HTTP::Params, HTTP::Client::Response).new { |request, params| #{yield} }" %}
          {{method.downcase.id}}(\{{pattern}}, \{{action.id}})
        end
      {% end %}
    end

    @mountpoint : String

    def initialize(mountpoint = "")
      @mountpoint = mountpoint.gsub(/\/$/, "")
    end
  end
end
