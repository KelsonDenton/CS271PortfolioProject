# CS271 Portfolio Project
Final Project for CS271 class at OSU completed December 2021.

Project is written in Assembly language x86 and uses Irvine Library procedures. 

When run the .asm file will prompt the user for 10 integers to be entered and will 
then display all integers back to the user, the sum off all integers, and the average of all 
integers. Input validation prevents users from entering any numbers that are not integers or 
are too large to be stored in a 32-bit register.

This project was completed with only the use of Irvine ReadString and WriteString procedures,
meaning that string primitives and conversion from string to integers for arithmatic operations
were implemented. These conversions are performed in the WriteVal and ReadVal procedures
that are written in the .asm file.
