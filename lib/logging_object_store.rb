class LoggingObjectStore

  def initialize(object_store, log_file)
    @object_store = object_store
    @log_file = log_file
    @i = 0
  end

  def []=(id,value)
    @i += 1
    @log_file.puts @i if @i % 10000 == 0
    @object_store[id] = value
  end

  def <<(value)
    @i += 1
    @log_file.puts @i if @i % 10000 == 0
    @object_store << value
  end

  def nil?(id)
    @object_store.nil?(id)
  end
  
  def method_missing(method, *args)
    return @object_store.send(method, *args) if @object_store.respond_to?(method)
    super
  end
end

