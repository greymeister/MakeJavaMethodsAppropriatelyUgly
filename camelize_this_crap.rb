#!/usr/bin/env ruby

require 'fileutils'
require 'tempfile'

class String
  def camelize(first_letter_in_uppercase = false)
    if first_letter_in_uppercase
      self.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      self[0] + camelize(self)[1..-1]
    end
  end
end

ARGV.each do |java_file|
  puts "Camel casing methods in #{File.basename(java_file)}"
  temp_file = Tempfile.new(File.basename(java_file))
  File.open(java_file, 'r') do |file|
    file.each_line do |line|
      camel_cased_line = line.gsub(/[A-Za-z]_[A-Za-z]/) {|atom| atom.camelize}
      temp_file.puts camel_cased_line
    end
  end  
  temp_file.close
  FileUtils.mv(temp_file.path, java_file)
end

