#!/usr/bin/env ruby

def cleanfile(inputfile, outputfile)

  text = File.open(inputfile).read
  f = File.new(outputfile,"w")
  
  text.gsub!(/\r\n?/, "\n")
  
  text = text.split("\n")
  
  text.delete_if { |l| l =~ /^\s*$/ }
  
  prev_l = ""
  for l in text do
    combining = true
    combined = " " * [l.length, prev_l.length].max
    maxlength = [l.length, prev_l.length].max
    minlength = [l.length, prev_l.length].min
    for i in 0..minlength-1 do
      if combining 
        if l[i] == " " 
          combined[i] = prev_l[i]
        end
        if prev_l[i] == " " 
          combined[i] = l[i]
        end
        if l[i] != " " and prev_l[i] != " "
          combining = false
        end
      end
    end
  
    if combining
      if l.length > prev_l.length
         combined[minlength..maxlength] = l[minlength..maxlength]
      else
         combined[minlength..maxlength] = prev_l[minlength..maxlength]
      end
      f.write combined+"\n"
    else
      f.write l+"\n"
    end
    
    prev_l = l
  end


end








