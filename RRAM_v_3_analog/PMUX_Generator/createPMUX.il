procedure( createPMUX(						; LIST OF ARGUMENTS
						B					; NUMBER OF BITS OF A WORD
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
					)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
				NAME				; CELLVIEW NAME
				CELLVIEW			; DB OF CELLVIEW
				PIN_LIST			; VARIABLE TO HOLD PIN LIST
				INST_NAME		; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
			)

	printf("\n+++++++++++++++++++++++++++++++\n")
	printf("\n Running: createPMUX procedure \n")
	printf("\n+++++++++++++++++++++++++++++++\n")

	; STEP 1
	; CREATE PMUX BLOCK SCHEMATIC
	sprintf(INST_NAME "PMUX_BLOCK_%d>" B) 
	CELLVIEW = createPMUXblocksch(LIBRARY NAME B)

	; STEP 2
	; Create Symbol for RRAM ROW
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")



	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
