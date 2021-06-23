;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			23/06/2021
; Description:	This file contains the SKILL code to create the Schematic of the PMUX
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createPMUXsch(						; LIST OF ARGUMENTS
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

	; Create Instances			
	dbCreateInst(CELLVIEW DB_MUX_BLOCK_CELL "MREF" list(10 0) "R0")


	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.625:0.6875 0.625:2) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.625:2 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(10.625:0.6875 10.625:2) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 10.625:2 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VDD net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.75:0.6875 0.75:1.8) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.75:1.8 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VDD net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(10.75:0.6875 10.75:1.8) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 10.75:1.8 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create OUT net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.875:0.6875 0.875:1.6) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "OUT<(1:%d)*%d>" B X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.875:1.6 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create OUT net for ref
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(10.875:0.6875 10.875:1.6) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "OUT<%d:%d>" B+1 B+B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 10.875:1.6 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create BL unique for every cell
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1:0.6875 1:1.4) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "BL<1:%d>" X)
	schCreateWireLabel( CELLVIEW car(NET_ID) 1:1.4 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create BL unique for REF
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(11:0.6875 11:1.4) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "BL<%d:%d>" X+1 X+B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 11:1.4 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create EN net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-2:0 0:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "EN<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -2:0 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create EN net common for REF
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(8:0 10:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "EN<%d>" X/B+1)
	schCreateWireLabel( CELLVIEW car(NET_ID) 8:0 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	
	; Create NOT_EN net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-1.8:-0.125 0:-0.125) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "NOT_EN<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -1.8:-0.125 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_EN net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(8.2:-0.125 10:-0.125) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "NOT_EN<%d>" X/B+1)
	schCreateWireLabel( CELLVIEW car(NET_ID) 8.2:-0.125 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create Pins
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil 0.625:2 "R0" nil nil "ground")		; VSS
	
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VDD" "inputOutput" nil 0.75:1.8 "R0" nil nil "ground")		; VSS

	; OUT
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0:10 5:10) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "OUT<1:%d>" B+B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0:10 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )	
	sprintf(PIN_NAME "OUT<1:%d>" B+B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0:10 "R0" )		
	
	; BL
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0:12 5:12) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "BL<1:%d>" X+B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0:12 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "BL<1:%d>" X+B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0:12 "R0" )		
	
	; EN
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0:14 5:14) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "EN<1:%d>" X/B+1)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0:14 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "EN<1:%d>" X/B+1)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil 0:14 "R0" )		
	
	; NOT_EN
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0:16 5:16) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "NOT_EN<1:%d>" X/B+1)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0:16 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "NOT_EN<1:%d>" X/B+1)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil 0:16 "R0" )		


	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
