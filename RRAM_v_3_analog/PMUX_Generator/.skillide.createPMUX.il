;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			15/06/2021
; Description:	This file contains the SKILL code to create the Schematic of a MUX 
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createPMUX(						; LIST OF ARGUMENTS
						X					; X SIZE OF ARRAY (COLS), NUMBER OF MEMORY CELLS PER HORIZONTAL LINE
						B					; NUMBER OF BITS OF A WORD
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
						(TYPE	"P")			; P OR N
					)		; END OF LIST OF ARGUMENTS

	prog(	(					; LIST OF LOCAL VARIABLES
				NAME				; CELLVIEW NAME
				CELLVIEW_BLOCK	; DB OF CELLVIEW
				PIN_LIST			; VARIABLE TO HOLD PIN LIST
				ERROR_CODE		; ERROR CODE TO BE RETURNED
				CELLVIEW			; DB OF CELLVIEW
			)

	printf("\n+++++++++++++++++++++++++++++++\n")
	printf("\n Running: createMUX procedure \n")
	printf("\n+++++++++++++++++++++++++++++++\n")

	; STEP 0
	; CHECK THAT B is an integer divider of X
	if( modulo( X B) != 0
		then
		printf("The division of %d with %d is NOT 0\n" X B)
		ERROR_CODE = -20
		printf("ERROR: %d --- MUX ARGUMENTS SIZE WRONG\n" ERROR_CODE)
		return(ERROR_CODE) 
	)

	; STEP 1
	; CREATE MUX BLOCK SCHEMATIC
	sprintf(NAME "MUX_BLOCK_%d" B) 

	if( ddGetObj( LIBRARY NAME) == nil
		then
		CELLVIEW_BLOCK = createMUXblocksch(LIBRARY NAME B)
		if( CELLVIEW_BLOCK == nil
			then		
			ERROR_CODE = -21
			printf("ERROR: %d --- createMUX -> createMUXblocksch\n" ERROR_CODE)
			return(ERROR_CODE) 
		)
	
		; STEP 2
		; Create Symbol for P BLOCK of B P SWITCHES
		PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
		schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")

		; STEP 3
		; Create Layout
		; TODO

		else
			printf("%s already exists. Creation was skipped.\n" NAME)
			CELLVIEW_BLOCK = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "r")
	);if

	; STEP 4
	; Create MUX SCHEMATIC
	; Set the NAME of the CELLVIEW
	if( TYPE == "N"
		then
		sprintf(NAME "NMUX_%d_%d" B X/B)

		else
		sprintf(NAME "PMUX_%d_%d" B (X/B+1))
	) ;if
	
	if( ddGetObj( LIBRARY NAME) == nil
		then
		CELLVIEW = createPMUXsch( X B LIBRARY NAME dbOpenCellViewByType(CELLVIEW_BLOCK~>libName CELLVIEW_BLOCK~>cellName "symbol" "" "r"))

		; STEP 5
		; Create Symbol for PMUX
		PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
		schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")
	
	
		; STEP 6
		; TO DO LAYOUT
	else
		printf("%s already exists. Creation was skipped.\n" NAME)		
		CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "r")	
	);if
	
	
	

	return(CELLVIEW)			

	)	; prog
)	; procedure
