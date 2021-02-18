;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			18/02/2021
; Description:	This file contains the SKILL to create the layout of the RRAM
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAMlayout(					; LIST OF ARGUMENTS
								X 				; X SIZE OF ARRAY (COLS)
								Y				; Y SIZE OF ARRAY (ROWS)
								LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
								NAME				; NAME OF THE CELLVIEW
								DB_RRAM_CELL		; DB OF RRAM CELL
							)
	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL
			TF			; DB OF TECHNOLOGY FILE
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
			DB_INST		; TEMPORARY VARIABLE OF INSTANCE TO BE PLACED
			DB_RRAM_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			NET_ID_VSS	; VARIABLE TO HOLD VSS NET ID
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB
			GUARD_RING_DIST	; DISTANCE OF GUARNDING ON X/Y-AXIS
			DX			;	DIFF to adjust guard ring on X
			DY			;	DIFF to adjust guard ring on Y
			PATH_ID		; PATH DB			
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("Creating Layout.\n")

	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view
	TF = techGetTechFile(CELLVIEW)	; read technology file
	DB_RRAM_CELL_LAYOUT = dbOpenCellViewByType(DB_RRAM_CELL~>libName DB_RRAM_CELL~>cellName "layout" "maskLayout" "r")
	
	; Variables for guard rings and VSS
	DX = 0.89
	DY = 0.89
	
	for( i 1 Y			; ROWS
		for( j 1 X			; COLS
			
			; PLACE (j,i)
			printf("Placing CELL (%d,%d)\n" j i)
			sprintf(INST_NAME "I_%d_%d" j i)

			if( (modulo(j 2)==1) 
				then
				DB_INST=dbCreateInst(CELLVIEW DB_RRAM_CELL_LAYOUT INST_NAME list(j*5 i*2.28) "R90" 1)
				else
				DB_INST=dbCreateInst(CELLVIEW DB_RRAM_CELL_LAYOUT INST_NAME list((j-1)*5 i*2.28) "MXR90" 1)		; j-1 be careful the mirroring
			)	; then

			; CREATE LABEL/PINS VSS/SEL
			;if(	(i==1 && modulo(j 2)==1) 
			if(	(i==1 && j==1)
				then
				;if( (j==1)	;VSS
					;then
					NET_ID_VSS=dbMakeNet(CELLVIEW "VSS")
				;)	;then
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(((j-1)*5-0.115):4.445 ((j-1)*5+0.115):4.675))
				dbAddFigToNet(RECT_ID NET_ID_VSS)
				PIN_ID=dbCreatePin(NET_ID_VSS RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") ((j-1)*5):4.56 "VSS" "upperCenter" "R0" "roman" 0.5)		
				PIN_ID~>term~>direction = "inputOutput"
				leAttachFig(LABEL_ID PIN_ID~>fig)		

				; Connect to guard ring
				PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(0.26:2.78 0.26:(2.78-DY)) 0.94)
				dbAddFigToNet(PATH_ID NET_ID_VSS)
				PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(0.26:(4.56 +(Y-1)*2.28+1.78) 0.26:(4.56 +(Y-1)*2.28+1.78 + DY)) 0.94)
				dbAddFigToNet(PATH_ID NET_ID_VSS)

				PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list((5*X+0.21-0.94/2):2.78 (5*X+0.21-0.94/2):(2.78-DY))  0.94)
				dbAddFigToNet(PATH_ID NET_ID_VSS)
				PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list((5*X+0.21-0.94/2):(4.56 +(Y-1)*2.28+1.78) (5*X+0.21-0.94/2):(4.56 +(Y-1)*2.28+1.78 + DY))  0.94)
				dbAddFigToNet(PATH_ID NET_ID_VSS)
		
			)	;then

			if(	(i==1 && j!=1 && j!=X && modulo(j 2)==1)
				then
				PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(((j-1)*5):2.78 ((j-1)*5):(2.78-DY))  1.46)
				dbAddFigToNet(PATH_ID NET_ID_VSS)
				PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(((j-1)*5):(4.56 +(Y-1)*2.28+1.78) ((j-1)*5):(4.56 +(Y-1)*2.28+1.78 + DY))  1.46)
				dbAddFigToNet(PATH_ID NET_ID_VSS)
			)

			if( (j==1)
				then
				sprintf(NET_NAME "SEL<%d>" i)	; 	Rows share SEL
				NET_ID=dbMakeNet(CELLVIEW NET_NAME)
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((5-0.115):(4.56/2 + i*4.56/2-0.115) (5+0.115):(4.56/2 + i*4.56/2+0.115)))
				dbAddFigToNet(RECT_ID NET_ID)
				PIN_ID=dbCreatePin(NET_ID RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 5:(4.56/2 + i*4.56/2) NET_NAME "upperCenter" "R0" "roman" 0.5)		
				PIN_ID~>term~>direction = "input"
				leAttachFig(LABEL_ID PIN_ID~>fig)	
			)
			
			if(	(i==1 && modulo(j 2)==0 && j==X)		; Final VSS column
				then
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((j*5-0.115):4.445 (j*5+0.115):4.675))
				dbAddFigToNet(RECT_ID NET_ID_VSS)
				PIN_ID=dbCreatePin(NET_ID_VSS RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (j*5):4.56 "VSS" "upperCenter" "R0" "roman" 0.5)		
				PIN_ID~>term~>direction = "inputOutput"
				leAttachFig(LABEL_ID PIN_ID~>fig)
			)	;if

			if( i==1
				then
				sprintf(NET_NAME "N<%d>" j)	; 	Rows share N
				NET_ID=dbMakeNet(CELLVIEW NET_NAME)
				if( modulo(j 2)==1
					then							
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((2.77-0.115+(j-1)*5):(3.42-0.115) (2.77+0.115+(j-1)*5):(3.42+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (2.77+(j-1)*5):3.42 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	

					else
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((2.23-0.115+(j-1)*5):(3.42-0.115) (2.23+0.115+(j-1)*5):(3.42+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (2.23+(j-1)*5):3.42 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
				)	;if
			)	;if
			
			if( i==1
				then
				sprintf(NET_NAME "P<%d>" j)	; 	Rows share N
				NET_ID=dbMakeNet(CELLVIEW NET_NAME)
				if( modulo(j 2)==1
					then							
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((0.39-0.14+(j-1)*5):(4.58-0.14) (0.39+0.14+(j-1)*5):(4.58+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (0.39+(j-1)*5):4.58 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	

					else
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((4.61-0.14+(j-1)*5):(4.58-0.14) (4.61+0.14+(j-1)*5):(4.58+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (4.61+(j-1)*5):4.58 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
				)	;if
			)	;if

			sprintf(NET_NAME "MR<%d>" ((i-1)*X+j))
			NET_ID=dbMakeNet(CELLVIEW NET_NAME)
			if( modulo(j 2)==1
				then							
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((3.31-0.115+(j-1)*5):(4.56+(i-1)*4.56/2-0.115) (3.31+0.115+(j-1)*5):(4.56+(i-1)*4.56/2+0.115)))
				dbAddFigToNet(RECT_ID NET_ID)
				PIN_ID=dbCreatePin(NET_ID RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (3.31+(j-1)*5):(4.56+(i-1)*4.56/2) NET_NAME "upperCenter" "R0" "roman" 0.5)		
				PIN_ID~>term~>direction = "inputOutput"
				leAttachFig(LABEL_ID PIN_ID~>fig)	

				else
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((1.69-0.115+(j-1)*5):(4.56+(i-1)*4.56/2-0.115) (1.69+0.115+(j-1)*5):(4.56+(i-1)*4.56/2+0.115)))
				dbAddFigToNet(RECT_ID NET_ID)
				PIN_ID=dbCreatePin(NET_ID RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (1.69+(j-1)*5):(4.56+(i-1)*4.56/2) NET_NAME "upperCenter" "R0" "roman" 0.5)		
				PIN_ID~>term~>direction = "inputOutput"
				leAttachFig(LABEL_ID PIN_ID~>fig)	

			)	;if

			
		)	; for j
	)	; for i

	; Create Guard Ring
	;---- TO DO: Create only straight lines and then create corners
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(0:(2.78-DY) (5*X+0.455+DX):(2.78-DY) (5*X+0.455+DX):(4.56 +(Y-1)*2.28+1.78 + DY) 0:(4.56 +(Y-1)*2.28+1.78 + DY)) ?netName "VSS")
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(0.42:(4.56 +(Y-1)*2.28+1.78 + DY) (-0.455-DX):(4.56 +(Y-1)*2.28+1.78 + DY) (-0.455-DX):(2.78-DY) 0.42:(2.78-DY)) ?netName "VSS")

	dbSave(CELLVIEW)		; Save
	)	; prog	
) 	; procedure
