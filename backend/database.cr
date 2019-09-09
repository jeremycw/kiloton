class Kiloton::Database

  @@instance : Database = self.new

  getter connection

  @connection : DB::Database

  def initialize
    @connection = DB.open "mysql://root:my-secret-root-password@127.0.0.1:10100/johnny5_development?initial_pool_size=10"
  end

  def self.connection
    @@instance.connection
  end
end
