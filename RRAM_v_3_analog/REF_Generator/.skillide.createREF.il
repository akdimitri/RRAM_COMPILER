;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			19/06/2021
; Description:	This file contains the main function SKILL code to create the RRAM REFERENCE ARRAY
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createREF(						; LIST OF ARGUMENTS
						Y					; Y SIZE OF ARRAY (ROWS)
						B					; B SIZE OF WORD LENGTH
						@optional 			; THE FOLLOWING ARGUMENTS ARE OPTIONAL, NEXT TO THEM IS THEIR DEFAULT VALUE
						(LIBRARY "THESIS")	; LIBRARY TO PLACE THE NEW DESIGN
						(DB_REF_CELL dbOpenCellViewByType("THESIS" "REF_NMOS" "symbol"))	; DB OF REFERENCE CELL
						(DX	5)				; HORIZONTAL PITCH
						(DY	2.28)			; VERTICAL PITCH
					)

	prog(	(			; LIST OF LOCAL VARIABLES
		NAME				; CELLVIEW NAME	
		CELLVIEW_ROW 	; DB OF ROW SCHEMATIC	
		PIN_LIST			; VARIABLE TO HOLD PIN LIST	
		CELLVIEW			; DB OF CELLVIEW	
	)					; END OF LIST OF LOCAL VARIABLES


	printf("\n+++++++++++++++++++++++++++++++\n")
	printf("\n Running: createREF procedure \n")
	printf("\n+++++++++++++++++++++++++++++++\n")

	; STEP 1
	; Create A Row of REF
	sprintf(NAME "_REF_%d" B)
	if( ddGetObj( LIBRARY NAME) == nil
		then
		CELLVIEW_ROW = createREFrowsch( B, LIBRARY, NAME, DB_REF_CELL)

		; STEP 2
		; Create Symbol for REF ROW
		PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
		schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")

		; STEP 3		
		; Create Layout for REF ROW
		createREFrowlayout(B LIBRARY NAME DB_REF_CELL DX)
	else
			printf("%s already exists. Creation was skipped.\n" NAME)
			CELLVIEW_ROW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "r")
	);if

	; Create REF Array
	sprintf(NAME "REF_%d_%d" B Y)
	if( ddGetObj( LIBRARY NAME) == nil
		then
		; STEP 4
		; Create Schematic for REF Array
		; Create Design and its schematic
		CELLVIEW = createREFsch(Y B LIBRARY NAME dbOpenCellViewByType(CELLVIEW_ROW~>libName CELLVIEW_ROW~>cellName "symbol" "" "r"))
		
		; STEP 5
		; Create Symbol
		PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
		schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")

		; STEP 6
		; Create Layout
		createREFlayout(	B Y	LIBRARY	NAME	 CELLVIEW_ROW DX	DY)

	else
		printf("%s already exists. Creation was skipped.\n" NAME)		
		CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "r")	
	);if

	printf("CreateREF(...) Function: DONE\n\n")
	return(CELLVIEW)

	)	; prog
)	; procedure
