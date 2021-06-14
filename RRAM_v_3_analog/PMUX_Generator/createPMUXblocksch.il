;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			14/06/2021
; Description:	This file contains the SKILL code to create the Schematic of a PMUX for a word of length <b>
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createPMUXblocksch(	LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
							NAME				; NAME OF THE CELLVIEW
							B				; NUMBER OF BITS OF A WORD
							@optional
							(P_SWITCH_CELL	dbOpenCellViewByType("THESIS" "P_SWITCH" "symbol")); DB OF P_SWITCH CELL							
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
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("+++ Creating Schematic for 1 block of P SWITCHES +++\n")

	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	
	
	; Create Instance
	sprintf(INST_NAME "M<1:%d>" B) 		
	dbCreateInst(CELLVIEW P_SWITCH_CELL INST_NAME list(0 0) "R0")

	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:-1.125 0.8125:-0.875) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.8125:-1.125 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create VDD net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:0.5625 0.8125:0.8125) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.8125:0.8125 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create NOT_EN net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.375:0.1875 0:0.1875) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.375:0.1875 "NOT_EN" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create RW net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.375:-0.125 0:-0.125) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.375:-0.125 "RW" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_RW net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.8125:-0.125 2.1875:-0.125) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 2.1875:-0.125 "NOT_RW" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create SA net. SA<1:B>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.375:-0.5 0:-0.5) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "SA<1:%d>" B)
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.375:-0.5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create WR net. WR<1:B>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.8125:-0.5 2.1875:-0.5) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "WR<1:%d>" B)	
	schCreateWireLabel( CELLVIEW car(NET_ID) 2.1875:-0.5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
	
	; Create P net. P<1:X>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.1875:0.5625 1.1875:0.8125) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<1:%d>" B)	
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.1875:0.8125 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create Pins
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil 0.8125:-1.125 "R0" nil nil "ground")		; VSS

	; VDD
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VDD" "inputOutput" nil 0.8125:0.8125 "R0" nil nil "ground")		; VSS

	; NOT_EN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "NOT_EN" "inputOutput" nil -0.375:0.1875 "R0" nil nil "ground")		; VSS
	
	; RW
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "RW" "inputOutput" nil -0.375:-0.125 "R0" nil nil "ground")		; VSS
	
	; NOT_RW
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "NOT_RW" "inputOutput" nil 2.1875:-0.125 "R180" nil nil "ground")		; VSS
	
	; P
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "P<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 1.1875:0.8125 "R0" )		
	
	; SA
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "SA<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -0.375:-0.5 "R0" )		
	
	; WR
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "WR<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 2.1875:-0.5 "R0" )		
	

	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
