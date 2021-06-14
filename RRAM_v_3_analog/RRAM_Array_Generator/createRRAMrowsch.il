;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			27/02/2021
; Description:	This file contains the SKILL code to create a row block of RRAM
; Version:		2
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAMrowSch(				; LIST OF ARGUMENTS
							X 				; X SIZE OF ARRAY (COLS)
							LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
							NAME				; NAME OF THE CELLVIEW
							DB_RRAM_CELL		; DB OF RRAM CELL
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
	
	printf("+++ Creating Schematic for 1 Row +++\n")
	
	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	

	; Create Instance
	sprintf(INST_NAME "M<1:%d>" X) 		
	dbCreateInst(CELLVIEW DB_RRAM_CELL INST_NAME list(0 0) "R0")
	
	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.25:-0.25 0.5:-0.25) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.7:-0.25 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create P net. P<1:X>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.125:0.0625 0.125:0.25) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<1:%d>" X)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.125:0.3 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create N net. N<1:X>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.125:-0.625 0.125:-0.375) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N<1:%d>" X)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.125:-0.675  NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )		
	
	; Create SEL is shared for a row
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.3125:-0.25 0:-0.25) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.3625:-0.25 "SEL" "upperCenter" "R0" "fixed" 0.05 nil )	

	; MR, every cell has its own MR net and a row style representation will be used for the final schematic
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.3125:-0.0625 0:-0.0625) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "MR<1:%d>" X)	; MR row representation
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.3625:-0.0625 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create Pins
	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil -1:0.5 "R0" nil nil "ground")		; VSS
	
	; SEL
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "SEL" "input" nil -1:1 "R0" )		; SEL
	
	; P
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "P<1:%d>" X)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -1:1.5 "R0" )		
	
	; N
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "N<1:%d>" X)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -1:2 "R0" )		
	
	; MR
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "MR<1:%d>" X)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -1:2.5 "R0" )	

	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
