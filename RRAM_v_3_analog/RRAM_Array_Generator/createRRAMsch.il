;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			27/02/2021
; Description:	This file contains the SKILL code to create the Schematic of the RRAM 
; Version:		2
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAMsch(	X				; LIST OF ARGUMENTS							
							Y				; Y SIZE OF ARRAY (ROWS)
							LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
							NAME				; NAME OF THE CELLVIEW
							DB_RRAM_CELL		; DB OF ROW RRAM CELL
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
	dbCreateInst(CELLVIEW DB_RRAM_CELL INST_NAME list(0 0) "R0")

	; Create VSS net common for all
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.5625:0.625 0.5625:2) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.5625:2 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P net. P<1:X>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.6875:0.625 0.6875:1.75) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<1:%d>" X)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.6875:1.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create N net. N<1:X>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:0.625 0.8125:1.5) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N<1:%d>" X)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.8125:1.5  NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create SEL net. SEL<1:Y>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.3125:0 0:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "SEL<1:%d>" Y)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0:0  NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create MR<1:XY>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.9375:0.625 0.9375:1.25) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "MR<1:%d>" X*Y)	; MR row representation
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.9375:1.25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; VSS	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil -1:0.5 "R0" nil nil "ground")		; VSS
	
	; SEL
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "SEL<1:%d>" Y)	; Columns share P
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -1:1 "R0" )		; SEL
	
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
	sprintf(PIN_NAME "MR<1:%d>" X*Y)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -1:2.5 "R0" )	


	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
