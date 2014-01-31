require 'token'
require 'fileutils'

class MarshalHelper

  def initialize(directory)
    @directory = directory
  end
  
  def dump(obj, name)
    ensure_directory
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

  def link(name, to)
    to.ensure_directory
    to_filename = to.filename(name)
    File.unlink(to_filename) if File.exists?(to_filename)
    File.symlink(File.absolute_path(filename(name)),to_filename)
  end

  def write(name)
    ensure_directory
    File.open(filename(name),'w') do |file|
      yield file
    end
  end

  def clear
    FileUtils.rm_rf(@directory)
  end
  
  def filename(name)
    File.join(@directory, name)
  end

  protected
  
  def ensure_directory
    Dir.mkdir(@directory) unless Dir.exist?(@directory)    
  end
end
