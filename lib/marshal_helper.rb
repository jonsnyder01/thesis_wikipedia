class MarshalHelper

  def initialize(directory)
    @directory = directory
  end
  
  def dump(obj, name)
    filename = File.join(@directory, name)
    puts "Dumping #{filename.to_s}"
    file = File.open(filename, 'w')
    Marshal.dump(obj, file)
    file.close
  end

  def load(name)
    filename = File.join(@directory, name)
    puts "Loading #{filename.to_s}"
    return nil unless File.exists?(filename)
    
    file = File.open(filename, 'r')
    obj = Marshal.load(file)
    file.close
    obj
  end
end
