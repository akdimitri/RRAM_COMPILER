;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			01/03/2021
; Description:	This file contains the main function SKILL code to create the RRAM 
; Version:		2
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createRRAM(		; LIST OF ARGUMENTS
						X 					; X SIZE OF ARRAY (COLS)
						Y					; Y SIZE OF ARRAY (ROWS)
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
						(DB_RRAM_CELL dbOpenCellViewByType("DIMITRIS_cell" "LV1T1R_NMOS_Pixel_v2" "symbol"))	; DB OF RRAM CELL
						(CELLMAP "/ibe/users/da220/Cadence/WORK_TSMC180FORTE/Calibre/rcx/calview.cellmap")		; CELLMAP FOR CALIBRE VIEW
					)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
				NAME				; CELLVIEW NAME
				CELLVIEW_ROW 	; DB OF ROW SCHEMATIC
				PIN_LIST			; VARIABLE TO HOLD PIN LIST
				time				; execution time
				time2			; execution time
				LOG				; LOG File
				my_log_port			; port to write to file
			)			; END OF LIST OF LOCAL VARIABLES

	printf("\n+++++++++++++++++++++++++++++++\n")
	printf("\n Running: createRRAM procedure \n")
	printf("\n+++++++++++++++++++++++++++++++\n")
	
	time = measureTime(

	; STEP 1
	; Create A Row of RRAM
	sprintf(NAME "_RRAM_%d" X)
	CELLVIEW_ROW = createRRAMrowsch( X,	LIBRARY,	NAME	, DB_RRAM_CELL)

	; STEP 2
	; Create Symbol for RRAM ROW
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")

	; STEP 3
	; Create Layout for RRAM ROW
	createRRAMrowlayout(X LIBRARY NAME DB_RRAM_CELL)
	
	; Set the NAME of the CELLVIEW
	sprintf(NAME "RRAM_%d_%d" X Y)
	
	; Create file to hold important information
	sprintf(LOG "%s/RRAM_COMPILER_LOG/%s.log" pwd() NAME)
	my_log_port = outfile( LOG "w")
	if( my_log_port==nil
		then
		ERROR_CODE = -12
		printf("ERROR: %d --- %s opening log file" ERROR_CODE library)
		return(ERROR_CODE)
	)

	; Create Design and its schematic
	createRRAMsch(X Y LIBRARY NAME dbOpenCellViewByType(CELLVIEW_ROW~>libName CELLVIEW_ROW~>cellName "symbol" "" "r"))

	; Create Symbol
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")
	
	; Create Layout
	createRRAMlayout(X Y LIBRARY NAME dbOpenCellViewByType(CELLVIEW_ROW~>libName CELLVIEW_ROW~>cellName "symbol" "" "r"))
	
	
	; Run DRC Calibre
	time2 = measureTime(runDRC_Calibre(LIBRARY NAME))
	printf("DRC Execution Time: %f\n" nthelem(3 time2))
	fprintf(my_log_port "DRC Execution Time: %f\n" nthelem(3 time2))

	; Run LVS Calibre
	time2 = measureTime(runLVS_Calibre(LIBRARY NAME))
	printf("LVS Execution Time: %f\n" nthelem(3 time2))
	fprintf(my_log_port "LVS Execution Time: %f\n" nthelem(3 time2))

	; Run PEX Calibre
	time2 = measureTime(runPEX_Calibre(LIBRARY NAME CELLMAP))
	printf("PEX+Calibre View Setup Execution Time: %f\n" nthelem(3 time2))
	fprintf(my_log_port "PEX+Calibre View Setup Execution Time: %f\n" nthelem(3 time2))

	); measureTime
	printf("Elapsed Time %f seconds" nthelem(3 time))
	fprintf(my_log_port "Elapsed Time %f seconds" nthelem(3 time))
	close(my_log_port)
	
	)	; prog
)	; procedure
