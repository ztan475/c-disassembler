require 'erb'

# Parsing the source file and generating the html text
def parseSource(text, dwarfdump)
    text.lines.map.with_index do |line, index|
      # Format line number with leading spaces
      # formattedNumber = format("%03d", index + 1)  # Add 3 leading zeros if needed
        
        # Extracts and prepares dwarf table
        dwarfTable = extractHexLines(dwarfdump)
        splitTable = splitDwarfTable(dwarfTable)

        sclick = ""
        aline = ""

        # Generate the sclick only if necessary
        splitTable.each_with_index do |row, i|
            if index.to_i + 1 == row[1].to_i
                sc = genSclick()
                sclick = "onclick=\"sclick('s#{index + 1}','a#{i + 1}')\""
                break
            end
        end

        # Generate the aline only if necessary
        splitTable.each_with_index do |row, i|
            if index.to_i + 1 == row[1].to_i
                aline = aline + "a#{i + 1} "
            end
        end
        

      "<button #{sclick}>#{index + 1}</button><span id=\"s#{index + 1}\"aline=\"#{aline}\">#{line}</span>"
    end.join("")
end

def genSclick()

end

# Helper functions for parsing the assembly file and generating the html text
# Extracts the table from dwarfdump
def extractHexLines(file_content)
  lines = []
  file_content.each_line do |line|
    if line.start_with?("0x")
        lines << line[2..-1] # Strip the 0x
    end
  end
  lines
end

# Removes elements in a 2D array that start with the new line character /n
def removeNewLines(array)
    new_array = []
    array.each do |row|
      new_row = row.select { |element| element[0] != "\n" }
      new_array.append(new_row)
    end
    return new_array
  end
  

# Extracts the segments from objdump using the string "Disassembly of section" as a marker
def getSegments(text)
    segments = []
    current_segment = []
    
    text.each_line do |line|
      if line.start_with?("Disassembly of section")
        segments << current_segment if current_segment.any?
        current_segment = []
      elsif !line.start_with?(" ") && !line.empty?
        current_segment << line
      end
    end
    
    segments << current_segment if current_segment.any?
    segments
end

# Format segments to prepare for string splitting
def format(seg)
    tempA = seg.gsub(" ", "")
    tempB = tempA.gsub("\n", "")
    tempC = tempB.gsub(":", ":\n")
    arr = tempC.split("\n")
    arr.each_with_index do |element, i|
        arr[i] = arr[i].slice(0, 16) + " " + arr[i].slice(16..-1)
    end
    str = arr.join("\n")
    
    return str
end

# Splits a dwarf table into a 2d array
def splitDwarfTable(dwarf_table)
    result = []
    dwarf_table.each do |element|
      if element.is_a?(String) # Check if it is a string
        split_elements = element.split(" ").map(&:strip) # Split on and strip leading and trailing spaces
        result << split_elements
      end
    end
    return result
end

# Finds code in objdump that correlates to the query which is an adress
def findCode(query, objdump)
    matching_lines = []
    in_block = false  # A flag to track if were within the block of lines
  
    objdump.each_line do |line|
      if line.start_with?(query)
        in_block = true
      elsif line.empty? || line == "\n"  # Check for empty line
        in_block = false
      end
  
      if in_block
        matching_lines << line
      end
    end
    return matching_lines
end

# Returns an array with the mappings of assembly lines to source code line where each element represents a single assembly line
def assignAclick(arr, dwarfTable)
    mapping = []
    currMapping = 0

    place = arr[0].split(":").map(&:strip) # Seperate to parse

    # Find where to start
    dwarfTable.each_with_index do |ddrow, index|
        address = place[0]

        remLeadingZero = ddrow[0].gsub(/^0+/, "") # Remove leading zeros
        if address.to_i(16) == remLeadingZero.to_i(16)
            currMapping = currMapping + 1 
            break
        end
        currMapping = currMapping + 1 
    end
    
    # Start assigning
    arr.each_with_index do |codeLine, index|
        if index != 0
            arrA = codeLine.split(":").map(&:strip)
            address = arrA[0]

            remLeadingZero = dwarfTable[currMapping][0].gsub(/^0+/, "")

            # Compare the address to teh dwarf dump address and add the corresponding mapping to an array called mapping
            if address.to_i(16) == remLeadingZero.to_i(16)
                mapping << dwarfTable[currMapping][1]
                currMapping = currMapping + 1 
            else
                mapping << dwarfTable[currMapping - 1][1]
            end
        end
    end
    return mapping
    
end

# Makes assembly into html format
def makeHTMLFormat(arr, dwarfTable, mapping, currLen)
    html = []
    stripped = arr.map(&:strip)

    # Remove first element and make header
    html << "\n#{stripped.shift}\n"
    arrAclick = mapping
    

    stripped.each_with_index do |element, index|
        num = arrAclick[index]
        aclick = "onclick=\"aclick('a#{index + 1 + currLen}','s#{arrAclick[index]}')\""
        # if dwarfTable[index].length == 7 
        #     # if dwarfTable[index] == "is_stmt"
        #     #     if dwarfTable[index + 1].length == 7 
        #     #         sline = generateSline

        #     #     end
        #     # end
        # else
        #     sline = arrAclick[index]
        # end
        sline = arrAclick[index]
        
        arrElem = element.split(":").map(&:strip)
        
        # The HTML format for assembly
        html << "<button #{aclick}>#{arrElem[0]}</button><span id=\"a#{index + 1 + currLen}\"sline=\"#{sline}\"> #{arrElem[1]}</span>"
      end
    joined = html.join("\n")
    return joined
end

# Main function for generating the html format of the assembly
def parseAssembly(objdump, dwarfdump)

    # Gets the segments from objdump and removes the first element
    # Prepares a 2D array to be parsed with objdump
    segAll = getSegments(objdump)
    segAll.shift
    seg = removeNewLines(segAll)

    seg.each_with_index do |row, i|
        if row[0].is_a?(String)  # Check if first element is a string
          seg[i][0] = row[0].split(" ")  # Split on space
        end
    end

    # Creates a 2D array for objdump
    formattedSeg = format(seg.join(""))
    arrSegs = []
    temp = formattedSeg.split("\n")
    temp.each do |elem|
        arr = elem.split(" ")
        arrSegs << arr
    end

    # Extracts and prepares dwarf table
    dwarfTable = extractHexLines(dwarfdump)
    splitTable = splitDwarfTable(dwarfTable)

    # Finds relevent labels in objdump referenced by dwarf dump
    foundLabels = []
    arrSegs.each_with_index do |address, i|
        # Find the first matching element in splitTable (if any)
        matching_element = splitTable.find { |dd_row| address[0] == dd_row[0] }
  
        # If a matching element is found, add its first element to found_labels
        if matching_element
            foundLabels << matching_element[0]
        end
    end

    # Finds the matching code for the listed labels
    labelCode = []
    foundLabels.each_with_index do |label, i|
        matchingCode = findCode(label, objdump)
        labelCode << matchingCode
    end
    
    # Formats assembly code into html format
    formatCode = ""
    mapping = []
    length = 0
    labelCode.each_with_index do |row, i|
        map = assignAclick(row, splitTable)
        mapping << map
        formattedCode = makeHTMLFormat(row, splitTable, map, length)
        length += row.length
        formatCode = formatCode + formattedCode + "\n"
    end

    formatCode
end

# Main disassembler function
def disassem(inputC, inputObjdump, inputDwarf, outputHTML)
    # Read the contents of the input files
    cfile = File.read(inputC)
    objdump = File.read(inputObjdump)
    dwarfdump = File.read(inputDwarf)

    style = File.read("style.css")
    scroll = File.read("scroll.js")


    # Escape any special characters to prevent HTML parsing errors
    # Parse the assembly file
    escapedObjdump = ERB::Util.html_escape(objdump)
    escapedDwarfdump = ERB::Util.html_escape(dwarfdump)
    parsedAssemblyFile = parseAssembly(escapedObjdump, escapedDwarfdump)
    
    # Parse the source file
    escapedCfile = ERB::Util.html_escape(cfile)
    parsedSourceFile = parseSource(escapedCfile, escapedDwarfdump)

    # Get rid of the extension for the header
    parts = inputC.split(".")
    filename = parts[0]

    # Build the HTML content
    html = "<!DOCTYPE html>
<html>
<style>
#{style}
</style>
<body>
<script>
#{scroll}
</script>

<h1>#{filename}</h1>

<table style=\"width:100%; table-layout:fixed\">
<tr>
<th style=\"width:55%\">
Source Code
</th>
<th style=\"width:1%\"></th>
<th style=\"width:44%\">
Assembly
</th>
</tr>
<tr>
<td style=\"overflow-x:scroll; vertical-align:top\">

<div id = \"source\">
#{parsedSourceFile}
</div>
</td>
<td></td>
<td style=\"overflow-x:scroll; vertical-align:top\">
<div id=\"assembly\">
#{parsedAssemblyFile}
</div>
</td>
</tr>
</table>
</body>
</html>"

  # Write the HTML content to the output file
  File.open(outputHTML, "w") { |file| file.write(html) }
end

# Checks if the right number of files was given by the user and give an error if not
if ARGV.length != 4
  puts "Error in number of files given."
  puts "Use: ruby disassem.rb <input.c> <objdump.txt> <dwarfdump.txt> <output.html>"
  exit
end


# Run the program with given inputs
input_cfile = ARGV[0]
input_objdump = ARGV[1]
input_dd = ARGV[2]
output_file = ARGV[3]

disassem(input_cfile, input_objdump, input_dd, output_file)