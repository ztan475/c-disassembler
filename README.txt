This program is a disassembler that takes an input of the source file, an object dump, and a dwarf dump, and 
returns a .html file that leads to a website that displays the mapping between source code lines and assembly lines. 

How to run - 
Use ruby with files as standard input
ruby disassem.rb <file>.c objdump.txt llvm-dwarfdump.txt <output>.html
<file> can be any c file
objdump and llvm-dwarfdump must correspond to the inputed c file
<output> is the name of the output


Files - ascii.c, disassem.rb, README.txt, llvm-dwarfdump.txt, objdump.txt, scroll.js, style.css

ascii.c - A C file used for testing

disassem.rb - A ruby file that contains the main code for the disassembler

README.txt - Project descriptions and guidelines.

llvm-dwarfdump.txt - A text file used for testing purposes.

objdump.txt - A text file used for testing purposes.

scroll.js - A JavaScript file that allows the user to scroll through the code. Taken from the given example.

style.css - A css file that allows the user to click, and formats the output html file. Taken from the given file.
