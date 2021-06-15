procedure( createPMUX(						; LIST OF ARGUMENTS
						X					; X SIZE OF ARRAY (COLS), NUMBER OF MEMORY CELLS PER HORIZONTAL LINE
						B					; NUMBER OF BITS OF A WORD
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
					)		; END OF LIST OF ARGUMENTS

	prog(	(					; LIST OF LOCAL VARIABLES
				NAME				; CELLVIEW NAME
				CELLVIEW_BLOCK		; DB OF CELLVIEW
				PIN_LIST			; VARIABLE TO HOLD PIN LIST
				ERROR_CODE		; ERROR CODE TO BE RETURNED
			)

	printf("\n+++++++++++++++++++++++++++++++\n")
	printf("\n Running: createPMUX procedure \n")
	printf("\n+++++++++++++++++++++++++++++++\n")
	
	; STEP 0
	; CHECK THAT B is an integer divider of X
	if( modulo( X B) != 0
		then
		printf("The division of %d with %d is NOT 0\n" X B)
		ERROR_CODE = -20
		printf("ERROR: %d --- PMUX ARGUMENTS SIZE WRONG\n" ERROR_CODE)
		return(ERROR_CODE) 
	)
	
	; STEP 1
	; CREATE PMUX BLOCK SCHEMATIC
	sprintf(NAME "PMUX_BLOCK_%d" B) 
	CELLVIEW_BLOCK = createPMUXblocksch(LIBRARY NAME B)
	if( CELLVIEW_BLOCK == nil
		then		
		ERROR_CODE = -21
		printf("ERROR: %d --- createPMUX -> createPMUXblocksch\n" ERROR_CODE)
		return(ERROR_CODE) 
	)

	; STEP 2
	; Create Symbol for P BLOCK of B P SWITCHES
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")

	; STEP 3
	; Create Layout
	; TODO

	; STEP 4
	; Create PMUX SCHEMATIC
	; Set the NAME of the CELLVIEW
	sprintf(NAME "PMUX_%d_%d" B X/B)
	createPMUXsch( X B LIBRARY NAME dbOpenCellViewByType(CELLVIEW_BLOCK~>libName CELLVIEW_BLOCK~>cellName "symbol" "" "r"))
	
	; STEP 5
	; Create Symbol for PMUX
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")


	return("SUCCESS")			

	)	; prog
)	; procedure
