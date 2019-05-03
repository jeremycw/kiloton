require "query-builder"

module Kiloton
  class Controller
    protected getter request, params

    @@database : DB::Database = DB.open "mysql://root:my-secret-root-password@127.0.0.1:10100/johnny5_development"

    def self.database
      @@database
    end

    def initialize(@request : HTTP::Request, @params : HTTP::Params)
    end

    def query
      ConcreteBuilder.new(@@database)
    end

    def database
      @@database
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
