# RRAM COMPILER

Author: 
            
            Antoniadis Dimitris

Supervisors:

            T. Constandinou
            P. Feng
            A. Misfud

e-mail: dimitris.antoniadis20@imperial.ac.uk

University: Imperial College London

Research Project: Large-scale mixed-signal array compiler for automatic memory generation

---
* This project is still ongoing 


**Research Project Description**: Commercial availability of memory complier is only used for industrial design of static random-access memory (SRAM) or
dynamic random-access memory (DRAM). In academia, a new memory type has been proposed by using memristor based
random-access memory (ReRAM). To design a large-scale ReRAM array is time consuming and tedious to custom design, and
there are not many tools for automating this process. This project aims to develop a script-based compiler that provides a
flexible and portable platform for generating and verifying ReRAM designs across different technologies.
The student will investigate the current memory compiler in terms of architecture and operation to understand the design
process of common memory.

The objectives are:
1. to develop an open source array compiler.
2. to design a large-scale ReRAM memory with essential peripheral circuits, such as sense amplifier, address decoder, write
driver, column multiplexer.

The expected outcome of this project is to realize the automatic ReRAM generation from schematic to layout togethering with
physical verification and timing/power characteristics. The deliverable outcome from the student will be a final report showing
Cadence implementation with main compiler components

**Instructions**

1. The RRAM MEMORY COMPILER files are SKILL code scripts and they have to be placed under folder SKILL in working directory. More specifically, under the working directory, in which the virtuoso command is invoked create a folder named SKILL.

>>mkdir SKILL


2. Under the working directory modify the .cdsinit file to load the corresponding scripts.

>>gedit .cdsinit

3. At the end of the file import the following lines of code.

>>setSkillPath( append( '("./SKILL/RRAM_COMPILER/RRAM_v_2") getSkillPath() ) )		; load path to personal skill scripts
>>
>>load("loadRRAM.il")
>>
>>loadRRAMCompiler()

4. Download RRAM COMPILER Repository and place folder RRAM_COMPILER inside folder SKILL

5. Run Compiler by invoking createRRAM function in CIW

For example:
>> createRRAM( 32, 32, "THESIS", dbOpenCellViewByType("DIMITRIS_cell" "LV1T1R_NMOS_Pixel_v2" "symbol"))	

**Function Definition**
createRRAM( X, Y, LIBRARY, DB)

X is the number of columns

Y is the number of rows

LIBRARY is the library where the result will be saved

DB is the db id of the symbol of the memristor cell

**Comparison of Versions**
The difference between version 1 and version 2 are in Schematic and Layout Implementation. The following two figures do not include the execution time of DRC, LVS, PEX where the same functions are used.

![Execution time in seconds. The x-axis refers to a RRAM array SIZExSIZE.](https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/Execution_withouth_verification.png)
![Speed up on the left axis. The x-axis refers to a RRAM array SIZExSIZE.](https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/speed_up_Execution_withouth_verification.png)
