
require 'timeout'

describe "Timeout Problem" do

  def timeout_test(timeout, task_length)
    Timeout::timeout(timeout) do
      sleep task_length
      raise "Hello"
    end    
  end
  
  it "raises inner exception" do
    100.times do
      expect { timeout_test(2, 1) }.to raise_error("Hello")
    end
  end
  it "raises outer exception" do
    100.times do
      expect { timeout_test(1, 2) }.to raise_error(Timeout::Error)
    end
  end
  it "raises one or the other exception" do
    100.times do
      expect { timeout_test(1, 1) }.to raise_error do |error|
        (error == "Hello" || error.is_a?(Timeout::Error)).should be_true
      end
    end
  end

  
end
