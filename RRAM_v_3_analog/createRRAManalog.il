;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			22/06/2021
; Description:	This file contains the main function SKILL code to create the RRAM Analog Part
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createRRAManalog(		; LIST OF ARGUMENTS
						X 					; X SIZE OF ARRAY (COLS)
						Y					; Y SIZE OF ARRAY (ROWS)
						B					; B (BITS) SIZE OF A WORD
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
						(DX 5)				; HORIZONTAL PITCH
						(DY 2.28)			; VERTICAL PITCH
						(DB_RRAM_CELL dbOpenCellViewByType("DIMITRIS_cell" "LV1T1R_NMOS_Pixel_v2" "symbol"))	; DB OF RRAM CELL
						(DB_REF_CELL dbOpenCellViewByType("THESIS" "REF_NMOS" "symbol"))	; DB OF REFERENCE CELL
						(CELLMAP "/ibe/users/da220/Cadence/WORK_TSMC180FORTE/Calibre/rcx/calview.cellmap")		; CELLMAP FOR CALIBRE VIEW
						(DB_SA dbOpenCellViewByType("THESIS" "SENSE_AMPLIFIER_LATCH_TYPE" "symbol"))
						(DB_WR dbOpenCellViewByType("THESIS" "WRITE_AMPLIFIER" "symbol"))
					)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
				NAME				; CELLVIEW NAME
				CELLVIEW 		; DB OF ROW SCHEMATIC
				DB_RRAM_SCH		; DB OF RRAM SCH CELLVIEW
				DB_PMUX_SCH	
				DB_NMUX_SCH		
				DB_REF_SCH
				;PIN_LIST			; VARIABLE TO HOLD PIN LIST
				;;time				; execution time
				;time2			; execution time
				;LOG				; LOG File
				;my_log_port			; port to write to file
			)			; END OF LIST OF LOCAL VARIABLES

	printf("\n+++++++++++++++++++++++++++++++\n")
	printf("\n Running: createRRAM Analog part procedure \n")
	printf("\n+++++++++++++++++++++++++++++++\n")

	; STEP 1
	; Create Create RRAM Array
	DB_RRAM_SCH = createRRAM(X Y LIBRARY DX DY DB_RRAM_CELL CELLMAP)

	; STEP 2
	; Create REF
	DB_REF_SCH = createREF(Y	B LIBRARY DB_REF_CELL)

	; STEP 3
	; Create NMUX
	DB_NMUX_SCH = createMUX(X B LIBRARY "N")	

	; STEP 4
	; Create PMUX
	DB_PMUX_SCH = createPMUX(X B LIBRARY "P")

	
	
	; STEP 5
	; Create RRAM Analog Part
	; Create Schematic View
	sprintf(NAME "A_RRAM_%d_%d_%d" X Y B)	
	CELLVIEW = createRRAManalogsch(X Y B LIBRARY NAME DB_RRAM_SCH DB_PMUX_SCH	 DB_NMUX_SCH	DB_REF_SCH DB_SA DB_WR)

	; STEP 6
	; Create Symbol
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")
	
	; STEP 7
	; Create Layout
	if( createRRAManaloglayout( X Y B	 LIBRARY	 NAME DB_RRAM_SCH DB_REF_SCH DB_PMUX_SCH DB_NMUX_SCH DX DY) == nil then
		printf("createRRAManaloglayout was ABORTED...\nExiting\n")	
		return("READ CIW FOR ERRORS")
	)

	; STEP 8
	runLVS_Calibre(LIBRARY NAME)

	printf("CreateRRAManalog(...) Function: DONE\n")

	return(CELLVIEW)
	
	)	; prog
)	; procedure
