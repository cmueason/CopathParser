#!/usr/local/bin/ruby

if (ARGV.length>0)
  $fileName = ARGV[0]
else
  puts("Input file name needed!")
  exit(0)
end

fileObj = File.new($fileName, "r")
$state = 0
@mylist = []

puts("sep=\t")
while ($line = fileObj.gets)

  if (($line =~ /^Gross/) or ($line =~ /^UCM/))
    #puts($line)
    $state = 0
  end

  if ($line =~ /^(S\d*-\d*)/)
    md = $line.match(/^(S\d*-\d*)/)
    $caseno = md[1]
    $state = 0
  end 

  if ($state == 1) 
    if (not ($line =~ /(Client)|(MRN)|(Location)|(Age:)|(Signed By)|(M\.D\.)/)) or ($line.length<=3)
      @mylist.push($line.gsub(/\n/," ").gsub(/\r/," ").gsub(/\t/," "))
    end
  end

  if ($line =~ /^Final/) 
    $state = 1
  end

  if ($state == 0) and (@mylist.length>0)
    $finaldx =  @mylist.join(" ").gsub(/\s+/," ").gsub(/^[\-\.\)=\s]+/,"").gsub(/^\s+/,"").gsub(/\-+/,"-")
    puts($caseno + "\t" + $finaldx)
    @mylist = []
  end

end
fileObj.close



