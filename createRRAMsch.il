procedure(	createRRAMsch(					; LIST OF ARGUMENTS
							X 				; X SIZE OF ARRAY (COLS)
							Y				; Y SIZE OF ARRAY (ROWS)
							LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
							NAME				; NAME OF THE CELLVIEW
							DB_RRAM_CELL		; DB OF RRAM CELL
						)
	prog( 	(			; LIST OF LOCAL VARIABLES
				CELLVIEW		; DB OF CELLVIEW
				INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
				INST_ID		; TEMPORARY VARIABLE to HOLD THE DB OF INSTANCE
				NET_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF THE NET
				NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
				PIN_CV_ID	; TEMPORARY VARIABLE TO HOLD THE DB OF THE PIN
				PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF NEW PIN
				PIN_NAME		; TEMPORARY VARIABLE TO HOLD THE NAME OF A PIN
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("+++ Creating Schematic +++\n")
	
	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	
	
	; Place Instances, Nets
	for( i 1 Y				; ROWS (Y Position)
		for( j 1 X			; COLS (X Position)
			
			; PLACE (j,i)
			printf("Placing CELL (%d,%d)\n" j i)
			; Define Instance Name
			sprintf(INST_NAME "I_%d_%d" j i)
			; Create Instance 		
			INST_ID = dbCreateInst(CELLVIEW DB_RRAM_CELL INST_NAME list((j-1) (i-1)) "R0" 1)
			; Create nets
			; VSS
			NET_ID = schCreateWire( CELLVIEW "draw" "full" list((j-1+0.25):(i-1-0.25) (j-1+0.4):(i-1-0.25)) 0.0625 0.0625 0.0 )
			schCreateWireLabel( CELLVIEW car(NET_ID) (j-1+0.35):(i-1-0.15) "VSS" "upperCenter" "R0" "fixed" 0.05 nil )
			
			; P	
			NET_ID = schCreateWire( CELLVIEW "draw" "full" list((j-1+0.125):(i-1+0.0625) (j-1+0.125):(i-1+0.25)) 0.0625 0.0625 0.0 )
			sprintf(NET_NAME "P<%d>" j)	; Columns share P
			schCreateWireLabel( CELLVIEW car(NET_ID) (j-1+0.105):(i-1+0.265) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
			; SEL
			NET_ID = schCreateWire( CELLVIEW "draw" "full" list((j-1-0.1875):(i-1-0.25) (j-1):(i-1-0.25)) 0.0625 0.0625 0.0 )
			sprintf(NET_NAME "SEL<%d>" i)	; Rows share SEL
			schCreateWireLabel( CELLVIEW car(NET_ID) (j-1-0.1975):(i-1-0.26) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
			; MR
			NET_ID = schCreateWire( CELLVIEW "draw" "full" list((j-1-0.25):(i-1-0.0625) (j-1):(i-1-0.0625)) 0.0625 0.0625 0.0 )
			sprintf(NET_NAME "MR<%d>" ((i-1)*X+j))	; MR row representation
			schCreateWireLabel( CELLVIEW car(NET_ID) (j-1-0.25):(i-1-0.0625) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
			; N	
			NET_ID = schCreateWire( CELLVIEW "draw" "full" list((j-1+0.125):(i-1-0.5625) (j-1+0.125):(i-1-0.375)) 0.0625 0.0625 0.0 )
			sprintf(NET_NAME "N<%d>" j)	; Shared P Pin
			schCreateWireLabel( CELLVIEW car(NET_ID) (j-1+0.125):(i-1-0.405) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
				
			; I11,I21 share N
			;if( modulo(i 2)==1
			;	then
			;	NET_ID = schCreateWire( CELLVIEW "draw" "full" list((j-1+0.125):(i-1-0.5625) (j-1+0.125):(i-1-0.375)) 0.0625 0.0625 0.0 )
			;	sprintf(NET_NAME "N_%d_%d%d" j i (i+1))	; Shared N Pin
			;	schCreateWireLabel( CELLVIEW car(NET_ID) (j-1+0.125):(i-1-0.405) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
			;	
			;	else
			;	NET_ID = schCreateWire( CELLVIEW "draw" "full" list((j-1+0.125):(i-1-0.5625) (j-1+0.125):(i-1-0.375)) 0.0625 0.0625 0.0 )
			;	sprintf(NET_NAME "N_%d_%d%d" j (i-1) i)	; Shared N Pin
			;	schCreateWireLabel( CELLVIEW car(NET_ID) (j-1+0.125):(i-1-0.405) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
			;	
			;)

		)	; for X
	)	; for Y

	; Create Pins	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	PIN_ID = schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil -1:0.5 "R0" nil nil "ground")		; VSS
	;----- TO DO -----
	; Set signal type to ground
	;------------------------	

	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "SEL<1:%d>" Y)
	PIN_ID = schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil -1:1.5 "R0" )		; SEL

	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "P<1:%d>" X)
	PIN_ID = schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -1:2.5 "R0" )		; P
	
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "N<1:%d>" X)
	PIN_ID = schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -1:3.5 "R0" )		; N

	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "MR<1:%d>" X*Y)
	PIN_ID = schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil -1:4.5 "R0" )		; N
	

	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
