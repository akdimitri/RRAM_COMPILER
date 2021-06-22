;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			22/06/2021
; Description:	This file contains the main function SKILL code to create the RRAM Array and REF
; Version:		2
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createRRAMarrayref(		; LIST OF ARGUMENTS
						X 					; X SIZE OF ARRAY (COLS)
						Y					; Y SIZE OF ARRAY (ROWS)
						B					; B SIZE OF WORD LENGTH
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
						(DX 5)				; HORIZONTAL PITCH
						(DY 2.28)			; VERTICAL PITCH
						(DB_RRAM_CELL dbOpenCellViewByType("DIMITRIS_cell" "LV1T1R_NMOS_Pixel_v2" "symbol"))	; DB OF RRAM CELL
						(DB_REF_CELL dbOpenCellViewByType("THESIS" "REF_NMOS" "symbol"))						; DB OF REF CELL
						(CELLMAP "/ibe/users/da220/Cadence/WORK_TSMC180FORTE/Calibre/rcx/calview.cellmap")		; CELLMAP FOR CALIBRE VIEW
					)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
				NAME				; CELLVIEW NAME
				CELLVIEW_ROW 	; DB OF ROW SCHEMATIC
				PIN_LIST			; VARIABLE TO HOLD PIN LIST
				;time				; execution time
				;time2			; execution time
				;LOG				; LOG File
				;my_log_port			; port to write to file
			)			; END OF LIST OF LOCAL VARIABLES

	printf("\n+++++++++++++++++++++++++++++++\n")
	printf("\n Running: createRRAMarrayref procedure \n")
	printf("\n+++++++++++++++++++++++++++++++\n")

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
	createRRAMrowlayout(X LIBRARY NAME DB_RRAM_CELL DX)
	
	; Set the NAME of the CELLVIEW
	sprintf(NAME "RRAM_%d_%d" X Y)
	
	; STEP 4
	; Create Design and its schematic
	createRRAMsch(X Y LIBRARY NAME dbOpenCellViewByType(CELLVIEW_ROW~>libName CELLVIEW_ROW~>cellName "symbol" "" "r"))
	
	; STEP 5
	; Create Symbol
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")
	
	; STEP 6
	; TO DO: REMOVE GUARDRING
	; Create Layout
	;createRRAMlayout(X Y LIBRARY NAME dbOpenCellViewByType(CELLVIEW_ROW~>libName CELLVIEW_ROW~>cellName "symbol" "" "r") DX DY)

	; STEP 7
	; CREATE REF CIRC
	createREF(Y	B LIBRARY DB_REF_CELL)
	
	

	printf("CreateRRAMarrayref(...) Function: DONE\n")
	
	)	; prog
)	; procedure
