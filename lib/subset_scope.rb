class SubsetScope
  def initialize(input_directory, output_directory)
    @input_directory = input_directory
    @output_directory = output_directory
  end

  def command
  end

  def input_database
    @input_database ||= DatabaseScope.new(input_marshal_helper)
  end

  def input_marshal_helper
    MarshalHelper.new(@input_directory)
  end

  def output_database
    @output_database ||= DatabaseScope.new(output_marshal_helper)
  end

  def output_marshal_helper
    MarshalHelper.new(@output_directory)
  end

end
