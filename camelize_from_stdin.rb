#!/usr/bin/env ruby

require 'fileutils'

require_relative 'lib/camelizer'


ARGV.each do |input_filename|
  puts "Camel casing methods in #{File.basename(input_filename)}"
  camelizer = Camelizer.new(input_filename)
  camelizer.camelize_file_lines
  result_filename = camelizer.write_replaced_lines_to_temp_file
  FileUtils.mv(result_filename, input_filename)
end

