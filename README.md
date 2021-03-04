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

------------------------------------------

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

createRRAM( X, Y, LIBRARY, DB, CELLMAP)

X is the number of columns

Y is the number of rows

LIBRARY is the library where the result will be saved

DB is the db id of the symbol of the memristor cell

CELLMAP is the path to calibre.cellmap file

----------------------------------------

**Comparison of Versions**

The difference between version 1 and version 2 are in Schematic and Layout Implementation. The following two figures do not include the execution time of DRC, LVS, PEX where the same functions are used. The show the execution time in seconds and the speed up for a RRAM array of SIZExSIZE.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/Execution_withouth_verification.png" width="400">
<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/speed_up_Execution_withouth_verification.png" width="400">

The algorithm complexity is the same for both versions equal to O(n^2) + c(n), where c(n) is the complexity of the Verification Algorithm of Calibre Tool. The second version is much faster on implementation because whole row blocks of RRAM are instantiated. Therefore the instantiaton of cells is of O(n) complexity. The first version instatiates the RRAM cell by cell and the complexity is O(n^2). However, both of them instatiate MR pins pin by pin in each row and line and this is why the second version has also O(n^2) complexity on implementation. Though, the speed up in second version is huge.

The image below shows the execution time including Calibre Verification(DRC, LVS, PEX, Calibre View Setup). It can be shown that Verification occupies the largest portion of execution time. As expected, because of the n^2 complexity of the algorithm, the execution time rises exponentially. 

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/execution_time_2.png" width="400">

The table below compares the execution times without verification of both versions and the execution time including verification of the second version. The second version achieves better perfomance including verification compared to the first version without including verification. The verification time is the main reason of slowing down the algorithm, since the larger th e size, the longer time it takes for the system to complete the DRC,LVS,PEX and Calibre View Setup. Out of the four verification operations, PEX and Calibre View Setup are the most time consuming. All the measurements are in **seconds**.

| SIZE | v1 without verification | v2 without verification | v2 with verification | v2 without verification/ v2 with verification |
| --- | --- | --- | --- | --- |
| 2 | 3.21 | 7.44 | 44.53 | 0.173 |
| 4 | 3.7 | 7.93 | 44.28 | 0.179 |
| 8 | 3.97 | 7.91 | 47.79 | 0.165 |
| 16 | 4.78 | 8.06| 57.61 | 0.139 |
| 32 | 11.66 | 8.4 | 108.61 | 0.077 |
| 64 | 101.76 | 29.51 |302.28 | 0.097 |
| 128 | 1815 | 68.55 | 1096.07 | 0.062 |

The second version creates a fully verified 256x256 RRAM array in 3970.3 seconds, while it takes 22132.72 seconds for a 512x512 array.

