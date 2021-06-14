;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			28/1/2021
; Description:	This file contains the main function SKILL code to create the RRAM 
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createRRAMrow(		; LIST OF ARGUMENTS
						X 					; X SIZE OF ARRAY (COLS)
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
						(DB_RRAM_CELL dbOpenCellViewByType("DIMITRIS_cell" "LV1T1R_NMOS_Pixel_v2" "symbol"))	; DB OF RRAM CELL
					)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
				NAME		; CELLVIEW NAME
				;PIN_P	; PIN P
				;PIN_N	; PIN N
				;PIN_SEL	; PIN SEL
				PIN_LIST	; LIST OF PINS
			)			; END OF LIST OF LOCAL VARIABLES

	printf("\n++++++++++++++++++++++++++++++++++\n")
	printf("\n Running: createRRAMrow procedure \n")
	printf("\n++++++++++++++++++++++++++++++++++\n")
	
	; Set the NAME of the CELLVIEW
	sprintf(NAME "_RRAM_ROW_%d" X)
	printf("NAME: %s\n" NAME)

	; Create Design and its schematic
	createRRAMrowsch(X LIBRARY NAME DB_RRAM_CELL)

	; Create Symbol
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	;----- TO DO -----
	; Check if symbol exists and set to Replace
	;-----------------		
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")
	
	; Create Layout
	;createRRAMlayout(X Y LIBRARY NAME DB_RRAM_CELL)

	; Run DRC Calibre
	;runDRC_Calibre(LIBRARY NAME)

	; Run LVS Calibre
	;runLVS_Calibre(LIBRARY NAME)

	; Run PEX Calibre
	;runPEX_Calibre(LIBRARY NAME)
	
	)	; prog
)	; procedure
