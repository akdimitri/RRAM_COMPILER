# Open-Source RRAM COMPILER

Author: 
            
            Antoniadis Dimitris

Supervisors:

            T. Constandinou
            P. Feng
            A. Mifsud

e-mail: dimitris.antoniadis20@imperial.ac.uk

University: Imperial College London

Research Project: Large-scale mixed-signal array compiler for automatic memory generation

-----------------------

* This project is still ongoing 
* Version 2: RRAM ARRAY GENERATOR (COMPLETED)
* Version 3: RRAM GENERATOR WITH PERIPHERAL CIRCUITS (IN PROGRESS)


**Research Project Description**: Commercial availability of memory complier is only used for industrial design of static random-access memory (SRAM) or
dynamic random-access memory (DRAM). In academia, a new memory type has been proposed by using memristor based
random-access memory (ReRAM). To design a large-scale ReRAM array is time consuming and tedious to custom design, and
there are not many tools for automating this process. This project aims to develop a script-based compiler that provides a
flexible and portable platform for generating and verifying ReRAM designs across different technologies.
The student will investigate the current memory compiler in terms of architecture and operation to understand the design
process of common memory.

--------------------------------

**Publications**

[Open-Source Memory Compiler for Automatic RRAM Generation and Verification](https://arxiv.org/abs/2104.14885)  (Preprint) to be presented on MWSCAS 2021

###### Abstract - The lack of open-source memory compilers in academia typically causes significant delays in research and design implementations. This paper presents an open-source memory compiler that is irectly integrated within the Cadence Virtuoso environment using physical verification tools provided by Mentor Graphics (Calibre). It facilitates the entire memory generation process from netlist generation to layout implementation, and physical implementation verification. To the best of our knowledge, this is the first open-source memory compiler that has been developed specifically to automate Resistive Random Access Memory (RRAM) generation. RRAM holds the promise of achieving high speed, high density and non-volatility. A novel RRAM architecture, additionally is proposed, and a number of generated RRAM arrays are evaluated to identify their worst case control line parasitics and worst case settling time across the memristors of their cells. The total capacitance of lines SEL, N and P is 5.83 fF/cell, 3.31 fF/cell and 2.48 fF/cell respectively, while the total calculated resistance for SEL is 1.28 Ohm/cell and 0.14 Ohm/cell for both N and P lines.

------------------------------------------

**Research Project Objectives**

1. to develop an open source array compiler.
2. to design a large-scale ReRAM memory with essential peripheral circuits, such as sense amplifier, address decoder, write
driver, column multiplexer.

The expected outcome of this project is to realize the automatic ReRAM generation from schematic to layout togethering with
physical verification and timing/power characteristics. The deliverable outcome from the student will be a final report showing
Cadence implementation with main compiler components

------------------------------

**Instructions**

0. Dependencies: This RRAM Compiler is currently using TSMC 180nm technology. The source code is based on the SKILL programming language. Therefore, this compiler needs TSMC PDK 180nm, Cadence Tools and Mentor Calibre tools for verification. Additionally, it needs the basic cellviews 1T1R, SA, WR etc which are used to generate RRAM and its peripheral circuits. 


1. The RRAM MEMORY COMPILER files are SKILL code scripts and they have to be placed under folder SKILL in working directory. More specifically, under the working directory, in which the virtuoso command is invoked create a folder named SKILL.

>>mkdir SKILL
>>
>>mkdir RRAM_COMPILER_LOG


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
>> createRRAM( 32, 32, "THESIS", dbOpenCellViewByType("DIMITRIS_cell" "LV1T1R_NMOS_Pixel_v2" "symbol"), 5, 2.28)

-----------------------------------	

**Function Definition**

createRRAM( X, Y, LIBRARY, DB, CELLMAP, DX, DY)

X is the number of columns

Y is the number of rows

LIBRARY is the library where the result will be saved (optional, it can be set directly on the skill code)

DB is the db id of the symbol of the memristor cell (optional, it can be set directly on the skill code)

CELLMAP is the path to calibre.cellmap file (optional, it can be set directly on the skill code)

DX is the horizontal pitch of the cells (optional, it can be set directly on the skill code, applies on 2nd version)

DY is the vertical pitch of the cells (optional, it can be set directly on the skill code, applies on 2nd version)

----------------------------------------

**RRAM Memory Cell**

The memory cell of the proposed RRAM consists of 1 memristor 1 transitor. The cellview in the EDA tool does not include the memristor, as it will be placed later on top of the memory cell. The schematic of a memory cell is shown on the next figure.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/RRAM_cell.png" width="400">

The RRAM Array is presented on the following image. The SEL lines are shared horizontally and P,N lines are shared vertically.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/RRAM_3_3.png" width="400">

**RRAM Memory Architecture**

The proposed simplified architecture is show on the image below. 

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/simplified_architecture.png" width="400">

**Sense Amplifiers**

All sense amplifiers were tested in an equaivalent testbech of 4Mb based on the results presented on 
[Open-Source Memory Compiler for Automatic RRAM Generation and Verification](https://arxiv.org/abs/2104.14885). The outputs of Sense Amplifiers in the testbench had been driving 50.47fF Capacitors. A 100 Monte Carlo Analysis was run on every Sense Amplifier for every possible combination found in the tables below. For the simulation the state was initialised to LRS (HRS) and then altered to HRS (LRS).

*Latch Type*

Based on [Design of Sense Amplifiers for Non-Volatile Memory](https://ieeexplore.ieee.org/document/8757026) and [Analysis of sense amplifier circuits in nanometer technologies](https://ieeexplore.ieee.org/abstract/document/8085666). Its schematic is shown below

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/latch_type.png" width="400">

| R (Ohm) | Ratio | 10n | 20n | 30n | 40n | 50n |
| --- | --- | --- | --- | --- | --- | --- |
| 1000     | 0.028571429 | 0%   |   100% |   100% |   100% |   100% |
| 2387     | 0.0682      | 0%   |   100% |   100% |   100% |   100% |
| 5700     | 0.162857143 | 0%   |   100% |   100% |   100% |   100% |
| 13611    | 0.388885714 | 0%   |   100% |   100% |   100% |   100% |
| 20000    | 0.571428571 | 0%   |   100% |   100% |   100% |   100% |
| 32500    | 0.928571429 | 0%   |   100% |   100% | 97 %   | 90%    |
| 40000    | 1.142857143 | 0%   | 0 %    | 30%    | 68%    | 86%    |
| 60000    | 1.714285714 | 0%   | 2      | 100%   |100%    | 100%   |
| 89442    | 2.555485714 | 0%   | 68%    | 100%   |100%    | 100%   |
| 200000   | 5.714285714 | 0%   | 100%   | 100%   |100%    | 100%   |
| 447213   | 12.77751429 | 0%   | 100%   | 100%   |100%    | 100%   |
| 1000000  | 28.57142857 | 0%   | 100%   | 100%   |100%    | 100%   |

**Analog Part Simplified Schematic**

The image shown below, shows a simplified version of the Analog Part of the RRAM generated by Version 3. Switches may be nmos switches or transmission gates. This image shows a RRAM Array of 4 x 4. The size of a word is 2 bits. A reference array is on the top right integrated in the RRAM Array schematic. The nmos transistors of the Reference array have resistance in between HRS and LRS of the memristor and facilitate a differential sensing in order to improve the accuracy.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/Dimitris_Project_Analog_RRAM_Architecture.png" width="1000">

--------------------------------

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

The following table presents the timing for every function involved in the RRAM creation and verification. The most time is consumed by PEX. Small variations of same size on different runs may be due to server cpus involved, servers usage etc.

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

The following image presents the above table. It shows that PEX, Calibre Setup View and Implementation share almost equal time for large arrays. However, the speed up of the second version remains huge. On the contrary, DRC and LVS time is almost negligble for large arrays.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/profiling_v2.png" width="400">

------------------------------------

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

The following image shows that C+CC rises linearly with regard to the number of cells of a line. 

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/c_cc.png" width="400">

The following image shows that R rises linearly with regard to the number of cells of a line. 

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/resistance.png" width="400">


**Settling Time**

The worst case settling time for TT model libray occurs for VN=5, VP=0 and R=5MΩ. In general, settling time increases as R increses. The settling time simulations are time consuming. Therefore, the following graph presents results only for arrays with size less than 128x128. It is clear that as array increases exponential, settling time increases too. For the worst case the top right Memristor was chosen. The input pins are placed on the lower left, so the top right Memeristor is expected to have the longest path and as such the worst settling time. The settling interval confidence was set equal to 99%.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/worst_settling.png" width="400">

The worst case settling time for SS model libray is shown on the next figure. It is the worst possible scenario for settling time across the memristor.

<img src="https://github.com/akdimitri/RRAM_COMPILER/blob/main/images/settling_ss.png" width="400">


**Known Problems**

Do not overwrite a RRAM Cellview. Delete and rerun the compiler. If a problem persists try removing potential .cdslck files and rerun virtuoso.
