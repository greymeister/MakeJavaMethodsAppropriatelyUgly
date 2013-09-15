require 'tempfile'

class Camelizer
  def initialize(filename)
    @filename = filename
    @replaced_lines = []
  end

  def camelize_file_lines()
    File.open(@filename, 'r') do |file|
      file.each_line {|line| @replaced_lines << self.camelize_line(line)}
    end  
  end

  def write_replaced_lines_to_temp_file()
    temp_file = Tempfile.new(File.basename(@filename))
    @replaced_lines.each {|line| temp_file.puts line}
    temp_file.close
    return temp_file.path
  end

  def camelize_line(line)
    return line.gsub(/([a-z]+_[a-z]+)+\(/) {|atom| atom.camelize}
  end
end

# Break open String class to add camelize method
class String
  def camelize(first_letter_in_uppercase = false)
    if first_letter_in_uppercase
      self.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      self[0] + camelize(self)[1..-1]
    end
  end
end
