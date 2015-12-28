#!/usr/bin/env ruby
MULTIPLE_BLANK_LINE_TO_ONE = false
SKIP_BLANK_LINES = true
PRINT_ORIGINAL = false 
SEP="\t"

class CopathCase
  attr_accessor :caseno, :gender, :race, :age, :birthday, :client, :mrn, :signoutdate,
    :accessiondate, :name, :submitting, :signedby, :location, :finaldx, :grossdx

  SHORTSTRING = false

  def initialize(caseno)
    @caseno = caseno
    @gender = @race = @age = @birthday = @client = @mrn = @signoutdate = @accessiondate = @name = @submitting = @signedby = @location = @finaldx =  @grossdx = ""
  end

  def toString(sep=SEP)    
    list = [@caseno,@accessiondate, @signoutdate, @name, @mrn,
            @gender, @race, @age, @birthday, @client, @submitting, 
            @signedby, @location, @finaldx.gsub(/^[ -]+/,""), @grossdx]
    if SHORTSTRING
      list = list.map { |x| x[0..20] }     
    end 
    return list.join(sep)    
  end

end


def processfile(inputFile, outputFile="")
  puts "sep="+SEP
  puts ["CaseNo","AccessionDate","SignoutDate","Name","MRN","Gender","Race","Age","Birthday","Client","Submitting","SignedBy","Location","FinalDx","GrossDx"].join(SEP)
 
  filename = inputFile
  file = File.open(filename, "r") 
  prev = thisblank = selcriteria = false
  prev_section = curr_section = currentcase = nil
  sectionlines = []

  file.each do |line|
    # defines lines to ignore
    if line =~ /UCM/ or line =~ /Page/ or line =~ /Total Number of Specim/ or line =~ /Date\/Time/  
      curr_section = :ignore
      next
    end

    # removing selection criteria
    if not selcriteria
      selcriteria = (line =~ /Selection Criteria: /)        
    end
    if selcriteria and (line =~ /S\d\d-\d+/)
      selcriteria = false
    end

    curr_section = :selcriteria if selcriteria 
  
    # detect sections
    if not selcriteria
      if (m = /^\s*(?<caseno>S\d\d-\d+)/.match(line))
        if not currentcase   # current case is empty, so must be new case
          # matches a new case, might just be a new page, might be a new case, might be a first case
          currentcase = CopathCase.new(m[:caseno])
        else # not new case, either a continuation or a different case
          if currentcase.caseno != m[:caseno]   # current case becomes a different case
            puts currentcase.toString()
            currentcase = CopathCase.new(m[:caseno])            
          end
        end
        curr_section = :case        
      end
      if (m = /Accession Date: (?<date>\d+\/\d+\/\d+)/.match(line))
        currentcase.accessiondate = m[:date]
        curr_section = :case        
      end
  
      if (m = /Signout Date: (?<date>\d+\/\d+\/\d+)/.match(line))
        currentcase.signoutdate = m[:date]
        curr_section = :case        
      end
  
      if (m = /Gender: (?<gender>\S+)/.match(line))
        currentcase.gender = m[:gender]
        curr_section = :case        
      end
  
      if (m = /Race: (?<race>.+)\s*Age/.match(line))
        currentcase.race = m[:race]
      end
  
      if (m = /Age: (?<birthdate>\d+\/\d+\/\d+)\s+\(\s+(?<age>\d+)\s+\)/.match(line))
        currentcase.age = m[:age]
        currentcase.birthday = m[:birthdate]
      end
  
      if (m = /Client: (?<client>.*+)$/.match(line))
        currentcase.client = m[:client]
      end
  
      if (m = /MRN: (?<mrn>\d+)/.match(line))
        currentcase.mrn = m[:mrn]
      end

      if (m = /Patient Name: (?<name>.*)\s{2}/.match(line))
        currentcase.name = m[:name].gsub(/\t/,"").gsub(/\s+$/,"")
      end

      if (m = /Submitting: (?<name>.*)\s+Signed/.match(line))
        currentcase.submitting = m[:name].gsub(/\t/,"").gsub(/\s+$/,"")
      end

      if (m = /Signed By: (?<name>.*)\s{2}/.match(line))
        currentcase.signedby = m[:name].gsub(/\t/,"").gsub(/\s+$/,"")
      end

      if (m = /Location: (?<location>.*)$/.match(line))
        currentcase.location = m[:location]
      end

      prev_section = curr_section
      if line =~ /Final Diagnosis/
        curr_section = :finaldx        
      elsif line =~ /Gross Description/
        curr_section = :grossdx
      end     

      if (prev_section == curr_section) 
        sectionlines.push(line.gsub(/^\s*/,"").gsub(/\s*$/,"").gsub("\n","").gsub("\r",""))   
      end

      if prev_section == :finaldx and curr_section == :finaldx
        myline = line.gsub(/^\s*/,"").gsub(/\s*$/,"").gsub("\n","").gsub("\r","") 
        currentcase.finaldx += myline.gsub(/^\s*/,"").gsub(/\s*$/,"").gsub("\n","").gsub("\r","").gsub(/^-\s*/,"") + " "
      end
   
      if prev_section == :grossdx and curr_section == :grossdx
        myline = line.gsub(/^\s*/,"").gsub(/\s*$/,"").gsub("\n","").gsub("\r","")   
        currentcase.grossdx += myline.gsub(/^\s*/,"").gsub(/\s*$/,"").gsub("\n","").gsub("\r","").gsub(/^-\s*/,"")
      end  
       
    end
 
    # turning multiple blank lines into one blank line
    prev = thisblank
    thisblank = (line =~ /^\s*$/)? true : false
   
    if PRINT_ORIGINAL
      if SKIP_BLANK_LINES
        if not thisblank
          puts line if not selcriteria
        end
      elsif not selcriteria
        puts line if not thisblank or (not prev and thisblank)
      end
    end
  end
  puts currentcase.toString()
end


### TEST ###
processfile(ARGV[0])

