;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			19/06/2021
; Description:	This file contains the SKILL code to create a row block of REF
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createREFrowsch(				; LIST OF ARGUMENTS
							B 				; B SIZE OF WORD
							LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
							NAME				; NAME OF THE CELLVIEW
							DB_REF_CELL		; DB OF RRAM CELL
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
	
	printf("+++ Creating REF Schematic for 1 Row +++\n")

	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	

	; Create Instance
	sprintf(INST_NAME "M<1:%d>" B) 		
	dbCreateInst(CELLVIEW DB_REF_CELL INST_NAME list(0 0) "R0")

	; Create SEL net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.5:0 0:0) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.5:0 "SEL" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P net. P<1:B>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.5:0.4375 0.5:0.75) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<1:%d>" B)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.5:0.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create N net. P<1:B>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.5:-1 0.5:-0.5) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N<1:%d>" B)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.5:-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create Pins
	; SEL
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "SEL" "input" nil -0.5:0 "R0" )		; SEL

	; P
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "P<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0.5:0.75 "R0" )		

	; N
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "N<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0.5:-1 "R0" )		

	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
