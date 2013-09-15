# camelizer spec

require 'camelizer'
require 'fileutils'

describe Camelizer, "#camelize_file_lines" do
  it "does nothing for non_existant file" do
    camelizer = Camelizer.new('NO_SUCH_FILE')
    camelizer.camelize_file_lines
    camelizer.replaced_lines.empty?.should eq (true)
  end

  it "captures all lines even if they don't match" do
    temp_file = Tempfile.new("fileWithNoSnakeCase")
    temp_file.puts "There is no snake case here!"
    temp_file.close
    camelizer = Camelizer.new(temp_file.path)
    camelizer.camelize_file_lines
    camelizer.replaced_lines.size.should eq (1)
    camelizer.replaced_lines[0].should eq ("There is no snake case here!\n")
    temp_file.delete
  end

  it "replaces lines that match" do
    temp_file = Tempfile.new("fileWithSomeSnakeCase")
    temp_file.puts "public void some_snake_case() {"
    temp_file.close
    camelizer = Camelizer.new(temp_file.path)
    camelizer.camelize_file_lines
    camelizer.replaced_lines.size.should eq (1)
    camelizer.replaced_lines[0].should eq ("public void someSnakeCase() {\n")
    temp_file.delete
  end
  
  it "replaces lines that match but not those that don't" do
    temp_file = Tempfile.new("fileWithBoth")
    temp_file.puts "// This is a comment with some meaning"
    temp_file.puts "public void some_snake_case() {"
    temp_file.close
    camelizer = Camelizer.new(temp_file.path)
    camelizer.camelize_file_lines
    camelizer.replaced_lines.size.should eq (2)
    camelizer.replaced_lines[0].should eq ("// This is a comment with some meaning\n")
    camelizer.replaced_lines[1].should eq ("public void someSnakeCase() {\n")
    temp_file.delete
  end
end

describe Camelizer, "#write_replaced_lines_to_temp_file" do
  it "copies the file contents into a temp file" do
    temp_file = Tempfile.new("fileToReplaceLines")
    temp_file.puts "// This is a comment with some meaning"
    temp_file.close
    camelizer = Camelizer.new(temp_file.path)
    camelizer.camelize_file_lines
    output_filename = camelizer.write_replaced_lines_to_temp_file
    camelizer.replaced_lines.size.should eq (1)
    FileUtils.compare_file(temp_file.path, output_filename).should eq (true)
    File.delete(output_filename)
    temp_file.delete
  end
end

describe Camelizer, "#camelize_line" do
  it "returns the same string if there are no snake_case atoms" do
    camelizer = Camelizer.new(double())
    camelizer.camelize_line('TestLine').should eq ('TestLine')
  end

  it "returns a camel cased string if there are snake_case() methods" do
    camelizer = Camelizer.new(double())
    camelizer.camelize_line('test_method()').should eq ('testMethod()')
  end

  it "ignores atoms that are UPPER_SNAKE_CASED like consts" do
    camelizer = Camelizer.new(double())
    camelizer.camelize_line('SOME_UGLY_CONST').should eq ('SOME_UGLY_CONST')
  end

  it "ignores methods with mixed_Snake_Case()" do
    camelizer = Camelizer.new(double())
    camelizer.camelize_line('test_Something()').should eq ('test_Something()')
  end

  it "only changes snake_cased portion of lines" do
    camelizer = Camelizer.new(double())
    camelizer.camelize_line('public void test_me(BIG_CONST who_cares)').should eq ('public void testMe(BIG_CONST who_cares)')
  end
end
