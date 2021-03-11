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

LIBRARY is the library where the result will be saved (optional, it can be set directly on the skill code)

DB is the db id of the symbol of the memristor cell (optional, it can be set directly on the skill code)

CELLMAP is the path to calibre.cellmap file (optional, it can be set directly on the skill code)

----------------------------------------

**Comparison of Versions**

The difference between version 1 and version 2 are in Schematic and Layout Implementation. The following two figures do not include the execution time of DRC, LVS, PEX where the same functions are used. They show the execution time in seconds and the speed up for a RRAM array of SIZExSIZE.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/Execution_withouth_verification.png" width="400">
<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/speed_up_Execution_withouth_verification.png" width="400">

The algorithm complexity is the same for both versions equal to O(n^2) + c(n), where c(n) is the complexity of the Verification Algorithm of Calibre Tool. The second version is much faster on implementation because whole row blocks of RRAM are instantiated. Therefore the instantiaton of cells is of O(n) complexity. The first version instantiates the RRAM cell by cell and the complexity is O(n^2). However, both of them instantiate MR pins pin by pin in each row and line and this is why the second version has also O(n^2) complexity on implementation. Though, the speed up in second version is huge.

The image below shows the execution time including Calibre Verification(DRC, LVS, PEX, Calibre View Setup). It can be shown that Verification occupies the largest portion of execution time. As expected, because of the n^2 complexity of the algorithm, the execution time rises exponentially. 

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/execution_time_2.png" width="400">

The table below compares the execution times without verification of both versions and the execution time including verification of the second version. The second version achieves better perfomance including verification compared to the first version without including verification. The verification time is the main reason of slowing down the algorithm, since the larger th e size, the longer time it takes for the system to complete the DRC,LVS,PEX and Calibre View Setup. Out of the four verification operations, PEX and Calibre View Setup are the most time consuming. All the measurements are in **seconds**. SIZE refers to an array of size equal to SIZExSIZE.

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

The following table presents the timing for every function involved in the RRAM creation and verification. The most time is consumed by PEX.

|SIZE | IMPLEMENTATION   | DRC       | LVS       | PEX         | SETUP       | TOTAL       |
|---  | ---              | ---       | ---       | ---         | ---         | ---         |
|2    | 7.50099          | 10.748419 | 8.942634  | 16.239728   | 5.383092    | 48.814863   |
|4    | 7.753175         | 10.596107 | 8.954458  | 16.240825   | 5.384769    | 48.929334   |
|8    | 7.675531         | 10.734499 | 8.663386  | 17.892335   | 6.716267    | 51.682018   |
|16   | 7.774973         | 11.296378 | 9.237844  | 23.56026    | 10.979237   | 62.848692   |
|32   | 8.042589         | 11.955142 | 9.28168   | 53.370914   | 29.845477   | 112.495802  |
|64   | 11.596684        | 13.300558 | 10.088026 | 169.807008  | 102.532625  | 307.324901  |
|128  | 44.291783        | 17.721942 | 11.997517 | 611.663116  | 409.871364  | 1095.545722 |
|256  | 496.515316       | 32.068824 | 19.154827 | 2101.401427 | 1675.637499 | 4324.777893 |
|512  | 7400.911615      | 80.894543 | 51.157234 | 7914.391475 | 7043.145462 | 22490.50033 |

**Parasitics Extraction**

PEX creates an net.summary under .PEX_Calibre folder inside cellview folder. By using a matlab script the following worst case C+CC (F) were calculated for arrays of SIZExSIZE. As the SIZE gets larger, the worst case C+CC gets larger.

|SIZE | SEL      | P        | N        | MR       | VSS      |
|---  | ---      | ---      | ---      | ---      | ---      |
|2    | 9.80E-15 | 4.74E-15 | 7.03E-15 | 3.18E-15 | 4.62E-15 |
|4    | 2.17E-14 | 9.81E-15 | 1.35E-14 | 3.20E-15 | 1.34E-14 |
|8    | 4.25E-14 | 1.87E-14 | 2.53E-14 | 3.20E-15 | 4.38E-14 |
|16   | 8.42E-14 | 3.65E-14 | 4.90E-14 | 3.20E-15 | 1.56E-13 |
|32   | 1.68E-13 | 7.21E-14 | 9.63E-14 | 3.20E-15 | 5.90E-13 |
|64   | 3.34E-13 | 1.43E-13 | 1.91E-13 | 3.20E-15 | 2.28E-12 |
|128  | 6.68E-13 | 2.86E-13 | 3.80E-13 | 3.20E-15 | 8.99E-12 |
|256  | 1.34E-12 | 5.70E-13 | 7.59E-13 | 3.20E-15 | 3.56E-11 |
|512  | 2.68E-12 | 1.14E-12 | 1.52E-12 | 3.20E-15 | 1.42E-10 |

The following image shows that C+CC rises linearly as array rises exponentail. SEL lines seem to have the most aggresive rise in total C+CC as the array scales up. A potential reason is that SEL line on each memristor cell is 5um compared to P,N which are 2.5 and in the arrays by sharing a delta Y is used of 2.28.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/c_cc.png" width="400">
