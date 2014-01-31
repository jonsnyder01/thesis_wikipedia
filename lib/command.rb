require 'open4'

module Command

  def self.run(command, out = $stdout, writer = nil)
    
    pid, p_stdin, p_stdout, p_stderr = Open4::popen4 command

    if writer
      Thread.new do
        writer.call p_stdin
      end
    else
      p_stdin.close
    end

    sleep 0
    while true
      ignored, status = Process::waitpid2( pid, Process::WNOHANG)

      if block_given?
        stdout_tail ||= ""
        stdout_tail = read_lines_nonblock( stdout_tail, p_stdout) { |line| yield line }
      else
        out.write read_nonblock(p_stdout)
      end
      $stderr.write read_nonblock(p_stderr)
      
      if status 
        if block_given? && stdout_tail != ""
          yield stdout_tail
        end
        if status != 0
          raise "Non-zero Return Code"
        end
        break
      end

      sleep 1
    end

    
  end

  def self.read_lines_nonblock( last_line, io)
    last_line += read_nonblock( io)
    lines = last_line.split("\n")

    last_line = (last_line[-1] == "\n" ? "" : lines.pop)

    lines.each do |line|
      yield line
    end
    last_line
  end
    
    
    
  def self.read_nonblock( io) 
    buf = ""
    while true
      buf += io.read_nonblock( 4096)
    end
  rescue IO::WaitReadable
    return buf
  rescue EOFError
    return buf
  end
end
