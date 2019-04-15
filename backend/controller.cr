module Kiloton
  class Controller
    protected getter request, params

    @@database : DB::Database = DB.open "mysql://root@127.0.0.1:3306/pool_development"

    def self.database
      @@database
    end

    def initialize(@request : HTTP::Request, @params : HTTP::Params)
      #@builder = Query::Builder.new
    end

    #def query
    #  @@database.query yield(@builder)
    #end

    #def exec
    #  @@database.exec yield(@builder)
    #end

    def database
      @@database
    end

  end
end
