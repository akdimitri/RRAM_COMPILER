;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			15/06/2021
; Description:	This file contains the SKILL code to create the Schematic of the MUX
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createMUXsch(						; LIST OF ARGUMENTS
							X					; X SIZE OF ARRAY (COLS), NUMBER OF MEMORY CELLS PER HORIZONTAL LINE
							B					; NUMBER OF BITS OF A WORD
							LIBRARY				; LIBRARY TO PLACE THE NEW DESIGN
							NAME					; NAME OF THE CELLVIEW
							DB_MUX_BLOCK_CELL	; DB OF BLOCK
						)
	prog( 	(				; LIST OF LOCAL VARIABLES
				CELLVIEW		; DB OF CELLVIEW
				INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
				ERROR_CODE		; ERROR CODE TO BE RETURNED
			)

	; Create Schematic View
	printf("createMUXsch Running\n")
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	
	if(	CELLVIEW == nil
		then
		printf("The division of %d with %d is NOT 0\n" X B)
		ERROR_CODE = -21
		printf("ERROR: %d --- MUX CELLVIEW CREATION FAILED" ERROR_CODE)
		return(ERROR_CODE) 
	)

	; Create Instances
	sprintf(INST_NAME "M<1:%d>" X/B) 		
	dbCreateInst(CELLVIEW DB_MUX_BLOCK_CELL INST_NAME list(0 0) "R0")

	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.625:0.6875 0.625:2) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.625:2 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VDD net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.75:0.6875 0.75:1.8) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.75:1.8 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create OUT net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.875:0.6875 0.875:1.6) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "OUT<(1:%d)*%d>" B X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.875:1.6 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create BL unique for every cell
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1:0.6875 1:1.4) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "BL<1:%d>" X)
	schCreateWireLabel( CELLVIEW car(NET_ID) 1:1.4 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create EN net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-2:0 0:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "EN<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -2:0 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create NOT_EN net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-1.8:-0.125 0:-0.125) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "NOT_EN<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -1.8:-0.125 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create Pins
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil 0.625:2 "R0" nil nil "ground")		; VSS
	
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VDD" "inputOutput" nil 0.75:1.8 "R0" nil nil "ground")		; VSS

	; OUT
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	;sprintf(PIN_NAME "OUT<(1:%d)*%d>" B X/B)
	sprintf(PIN_NAME "OUT<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0.875:1.6 "R0" )		
	
	; BL
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "BL<1:%d>" X)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 1:1.4 "R0" )		
	
	; EN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "EN<1:%d>" X/B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -2:0 "R0" )		
	
	; NOT_EN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "NOT_EN<1:%d>" X/B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -1.8:-0.125 "R0" )		


	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
