class LoggingObjectStore

  def initialize(object_store, log_file, frequency=10000)
    @object_store = object_store
    @log_file = log_file
    @frequency = frequency
    @i = 0
  end

  def []=(id,value)
    log_progress
    @object_store[id] = value
  end

  def <<(value)
    log_progress
    @object_store << value
  end

  def nil?(id)
    @object_store.nil?(id)
  end
  
  def method_missing(method, *args)
    return @object_store.send(method, *args) if @object_store.respond_to?(method)
    super
  end

  private

  def log_progress
    @i += 1
    @log_file.puts @i if @i % @frequency == 0
  end
end

