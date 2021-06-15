;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			15/06/2021
; Description:	This file contains the SKILL code to create the Schematic of a NMUX for a word of length <b>
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createNMUXblocksch(	LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
							NAME				; NAME OF THE CELLVIEW
							B				; NUMBER OF BITS OF A WORD
							@optional
							(N_SWITCH_CELL	dbOpenCellViewByType("THESIS" "N_SWITCH" "symbol")); DB OF N_SWITCH CELL							
						)
	prog( 	(			; LIST OF LOCAL VARIABLES
				CELLVIEW		; DB OF CELLVIEW
				INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
				;INST_ID		; TEMPORARY VARIABLE to HOLD THE DB OF INSTANCE
				NET_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF THE NET
				NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
				PIN_CV_ID	; TEMPORARY VARIABLE TO HOLD THE DB OF THE PIN
				;PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF NEW PIN
				PIN_NAME		; TEMPORARY VARIABLE TO HOLD THE NAME OF A PIN
				ERROR_CODE		; ERROR CODE TO BE RETURNED
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("+++ Creating Schematic for 1 block of N SWITCHES +++\n")
	
	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	
	if(	CELLVIEW == nil
		then		
		;ERROR_CODE = -21
		printf("ERROR: --- NMUX CELLVIEW CREATION FAILED")
		return(nil) 
	)
	
	; Create Instance
	sprintf(INST_NAME "M<1:%d>" B) 		
	dbCreateInst(CELLVIEW N_SWITCH_CELL INST_NAME list(0 0) "R0")

	; Create VDD net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.75:0.5625 0.75:0.875) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.75:0.875 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.75:-1.0625 0.75:-0.75) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.75:-1.0625 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create EN net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.375:0.125 0:0.125) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.375:0.125 "EN" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create NOT_EN net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.375:-0.125 0:-0.125) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.375:-0.125 "NOT_EN" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create N net. N<1:B>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.1875:0.5625 1.1875:0.875) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N<1:%d>" B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.1875:0.875 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create WR net. WR<1:B>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.1875:-1.0625 1.1875:-0.75) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "WR<1:%d>" B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.1875:-1.0625 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create Pins
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil 0.75:-1.0625 "R0" nil nil "ground")		; VSS
	
	; VDD	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VDD" "inputOutput" nil 0.75:0.875 "R0" nil nil "ground")		; VSS
	
	; WR
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "WR<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 1.1875:-1.0625 "R0" )		
	
	; N
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "N<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 1.1875:0.875 "R0" )		
	
	; EN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "EN" "input" nil -0.375:0.125 "R0" nil nil "ground")		; VSS
	
	; NOT_EN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "NOT_EN" "input" nil -0.375:-0.125 "R0" nil nil "ground")		; VSS
	
	
	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
