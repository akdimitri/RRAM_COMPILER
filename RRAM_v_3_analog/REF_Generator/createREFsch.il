;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			19/06/2021
; Description:	This file contains the SKILL code to create the Schematic of REF
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createREFsch(						; LIST OF ARGUMENTS							
							Y				; Y SIZE OF ARRAY (ROWS)
							B				; B SIZE OF WORD LENGTH
							LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
							NAME				; NAME OF THE CELLVIEW
							DB_REF_CELL		; DB OF ROW REF CELL
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
	
	printf("+++ Creating Schematic +++\n")

	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	

	; Create Row Instances
	sprintf(INST_NAME "RRAM_ROW<1:%d>" Y) 		
	dbCreateInst(CELLVIEW DB_REF_CELL INST_NAME list(0 0) "R0")

	; Create SEL unique for every cell
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.5:0 0:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "SEL<1:%d>" Y)
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.5:0 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P<1:B> net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.6875:0.625 0.6875:1) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<(1:%d)*%d>" B Y)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.6875:1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create N<1:B> net common for every block
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:0.625 0.8125:0.8) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N<(1:%d)*%d>" B Y)
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.6875:1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; PINS
	; SEL
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "SEL<1:%d>" Y)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -0.5:0 "R0" )	

	; P
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	;sprintf(PIN_NAME "P<(1:%d)*%d>" B Y)
	sprintf(PIN_NAME "P<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0.6875:1 "R0" )	

	; N
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	;sprintf(PIN_NAME "N<(1:%d)*%d>" B Y)
	sprintf(PIN_NAME "N<1:%d>" B)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil 0.8125:0.8 "R0" )	




	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
