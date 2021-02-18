# RRAM COMPILER

Author: Antoniadis Dimitrios

Supervisors:
            T. Constandinou
            P. Feng
            A. Misfud

e-mail: dimitris.antoniadis20@imperial.ac.uk

University: Imperial College London

Research Project: Large-scale mixed-signal array compiler for automatic memory generation

---
* This project is still ongoing 


**Research Project Description Description**: Commercial availability of memory complier is only used for industrial design of static random-access memory (SRAM) or
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

The RRAM MEMORY COMPILER files are SKILL code scripts and they have to be placed under folder SKILL in working directory. More specifically, under the working directory, in which the virtuoso command is invoked create a folder named SKILL.

>>mkdir SKILL


Under the working directory modify the .cdsinit file to load the corresponding scripts.

>>gedit .cdsinit

At the end of the file import the following lines of code.

>>setSkillPath( append( '("./SKILL/RRAM_COMPILER") getSkillPath() ) )		; load path to personal skill scripts
>>load("loadRRAM.il")
>>loadRRAMCompiler()
