;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			14/06/2021
; Description:	This file contains the SKILL code to create the Schematic of the PMUX
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createPMUXsch(						; LIST OF ARGUMENTS
							X					; X SIZE OF ARRAY (COLS), NUMBER OF MEMORY CELLS PER HORIZONTAL LINE
							B					; NUMBER OF BITS OF A WORD
							LIBRARY				; LIBRARY TO PLACE THE NEW DESIGN
							NAME					; NAME OF THE CELLVIEW
							DB_PMUX_BLOCK_CELL	; DB OF ROW RRAM CELL
						)
	prog( 	(				; LIST OF LOCAL VARIABLES
				CELLVIEW		; DB OF CELLVIEW
				INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
				ERROR_CODE		; ERROR CODE TO BE RETURNED
			)

	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	
	if(	CELLVIEW == nil
		then
		printf("The division of %d with %d is NOT 0\n" X B)
		ERROR_CODE = -21
		printf("ERROR: %d --- PMUX CELLVIEW CREATION FAILED" ERROR_CODE)
		return(ERROR_CODE) 

	)
	
	; Create Instances
	sprintf(INST_NAME "PMUX_BLOCK<1:%d>" X/B) 		
	dbCreateInst(CELLVIEW DB_PMUX_BLOCK_CELL INST_NAME list(0 0) "R0")

	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.6875:0.625 0.6875:1.8) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.6875:1.8 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create VDD net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:0.625 0.8125:1.6) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.8125:1.6 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create WR net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.5625:0.625 0.5625:2) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "WR<1:%d>" B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.5625:2 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create SA net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.9375:0.625 0.9375:1.4) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "SA<1:%d>" B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.9375:1.4 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create RW net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-1.4:-0.37 0:-0.37) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "RW<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -1.4:-0.37 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create NOT_RW net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-1.6:-0.25 0:-0.25) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "NOT_RW<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -1.6:-0.25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create NOT_EN net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-1.8:-0.12 0:-0.12) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "NOT_EN<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -1.8:-0.12 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create EN net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-2:0 0:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "EN<1:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -2:0 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create P lines
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.0625:0.625 1.0625:1.2) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<1:%d>" X)
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.0625:1.2 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create Pins
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil 0.6875:1.8 "R0" nil nil "ground")		; VSS

	; VDD	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VDD" "inputOutput" nil 0.8125:1.6 "R0" nil nil "ground")		; VSS
	
	; WR
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "WR<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0.5625:2 "R0" )		
	
	; SA
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "SA<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0.9375:1.4 "R0" )		
	
	; P
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "P<1:%d>" X)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 1.0625:1.2 "R0" )		
	
	; EN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "EN<1:%d>" X/B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -2:0 "R0" )		
	
	; NOT_EN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "NOT_EN<1:%d>" X/B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -1.8:-0.12 "R0" )		
	
	; NOT_RW
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "NOT_RW<1:%d>" X/B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -1.6:-0.25 "R0" )		
	
	; RW
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "RW<1:%d>" X/B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -1.4:-0.37 "R0" )		
	

	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	;prog
)	;procedure
