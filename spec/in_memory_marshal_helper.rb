class InMemoryMarshalHelper

  def initialize
    @memory = {}
  end

  def load(name)
    return nil if @memory[name].nil?
    Marshal.load(@memory[name])
  end

  def dump(obj, name)
    return if obj.nil?
    @memory[name] = Marshal.dump(obj)
  end
end
