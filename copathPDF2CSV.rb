#!/usr/bin/env ruby
require 'pdf/reader' # gem install pdf-reader
require './cleanfile'
require './copathcase'

# credits to :
# 	https://github.com/yob/pdf-reader/blob/master/examples/text.rb
# first, convert all pdf's to txt's

TESTING =false 

CONVERT_FROM_PDF_TO_TXT = !TESTING
CLEAN_TXT_UP = !TESTING
PROCESS_TXT = true
DELETE_TEMP_FILES = !TESTING 
EXCEL = true


if CONVERT_FROM_PDF_TO_TXT
  ARGV.each do |filename|
    PDF::Reader.open(filename) do |reader|
      puts "Converting : #{filename}"
      pageno = 0
      txt = reader.pages.map do |page| 
        pageno += 1
        begin
          print "Converting Page #{pageno}/#{reader.page_count}\r"
          page.text 
        rescue
          puts "Page #{pageno}/#{reader.page_count} Failed to convert"
          ''
        end
      end # pages map
      puts "\nWriting text to disk"
      File.write filename+'.txt', txt.join("\n")
    end # reader
  end # each
end
  
  # process each txt and output csv
if CLEAN_TXT_UP
  ARGV.each do |filename|
     cleanfile(filename+'.txt', filename+'.txt2')
  end
end

if PROCESS_TXT
  ARGV.each do |filename|
     processfile(filename+'.txt2', filename+'.csv', EXCEL)
  end
end

if DELETE_TEMP_FILES
  # finally, delete all txt's
  ARGV.each do |filename|
  #  File.delete filename+'.txt'
  #  File.delete filename+'.txt2'
  end
end
