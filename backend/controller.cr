module Kiloton
  class Controller
    protected getter request, params

    def initialize(@request : HTTP::Request, @params : HTTP::Params)
    end

    def query
      ConcreteBuilder.new(Database.connection)
    end

    def database
      Database.connection
    end

    class ConcreteBuilder < Query::Builder
      def initialize(@database : DB::Database)
        super()
      end

      def get_all
        query = super
        @database.query(query) do |rs|
          yield(rs)
        end
      end

      def get
        query = super
        @database.query(query) do |rs|
          yield(rs)
        end
      end

    end

  end
end
