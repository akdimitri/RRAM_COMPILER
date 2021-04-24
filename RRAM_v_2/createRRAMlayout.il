;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			01/03/2021
; Description:	This file contains the SKILL to create the layout of the RRAM
; Version:		2
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAMlayout(					; LIST OF ARGUMENTS
								X 				; X SIZE OF ARRAY (COLS)
								Y				; Y SIZE OF ARRAY (ROWS)
								LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
								NAME				; NAME OF THE CELLVIEW
								DB_RRAM_CELL		; DB OF RRAM CELL
								DX				; HORIZONTAL PITCH
								DY				; VERTICAL PITCH
							)
	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL
			;TF			; DB OF TECHNOLOGY FILE
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
			;DB_INST		; TEMPORARY VARIABLE OF INSTANCE TO BE PLACED
			DB_RRAM_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			NET_ID_VSS	; VARIABLE TO HOLD VSS NET ID
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB
			;GUARD_RING_DIST	; DISTANCE OF GUARNDING ON X/Y-AXIS
			;DX			;	DIFF to adjust guard ring on X
			;DY			;	DIFF to adjust guard ring on Y
			;PATH_ID		; PATH DB	
			k			; USED FOR WHILE LOOP		
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("Creating Layout.\n")

	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view
	DB_RRAM_CELL_LAYOUT = dbOpenCellViewByType(DB_RRAM_CELL~>libName DB_RRAM_CELL~>cellName "layout" "maskLayout" "r")	
	;dbCreateSimpleMosaic(CELLVIEW DB_RRAM_CELL_LAYOUT "RRAM_ROW" 0:0 "R0" Y 1 2.28 0)

	for( i 1 Y
		printf("Placing ROW %d\n" i)
		sprintf(INST_NAME "RRAM_ROW<%d>" i)
		dbCreateInst(CELLVIEW DB_RRAM_CELL_LAYOUT INST_NAME list(0 (i-1)*DY) "R0")
		
		; PIN SEL<i>
		sprintf(NET_NAME "SEL<%d>" i)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(4.885:i*DY-0.115 5.115:i*DY+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") DX:i*DY NET_NAME "upperCenter" "R0" "roman" 1)	
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)		
		
	)	;for

	; PIN VSS
	NET_ID_VSS=dbMakeNet(CELLVIEW "VSS")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(-0.115:2.165 0.115:2.395))
	dbAddFigToNet(RECT_ID NET_ID_VSS)
	PIN_ID=dbCreatePin(NET_ID_VSS RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:DY "VSS" "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)		

	for(j 1 X
		if( modulo(j 2)==1
				then		
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N		
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((2.77-0.115+(j-1)*DX):(1.14-0.115) (2.77+0.115+(j-1)*DX):(1.14+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (2.77+(j-1)*DX):1.14 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)		
			
					sprintf(NET_NAME "P<%d>" j)	; 	Rows share P			
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((0.39-0.14+(j-1)*DX):(2.3-0.14) (0.39+0.14+(j-1)*DX):(2.3+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (0.39+(j-1)*DX):2.3 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)				

				else
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((2.23-0.115+(j-1)*DX):(1.14-0.115) (2.23+0.115+(j-1)*DX):(1.14+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (2.23+(j-1)*DX):1.14 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
					
					sprintf(NET_NAME "P<%d>" j)
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((4.61-0.14+(j-1)*DX):(2.3-0.14) (4.61+0.14+(j-1)*DX):(2.3+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (4.61+(j-1)*DX):2.3 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)						
					
		);if			
	)	; for j


	
	
	
	k=1
	while(k<=X
		for(	 i 1 Y						
			sprintf(NET_NAME "MR<%d>" (i-1)*X+k)
			NET_ID=dbMakeNet(CELLVIEW NET_NAME)
			RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((3.31-0.115+(k-1)*DX):(DY*i-0.115) (3.31+0.115+(k-1)*DX):(DY*i+0.115)))
			dbAddFigToNet(RECT_ID NET_ID)
			PIN_ID=dbCreatePin(NET_ID RECT_ID)
			LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (3.31+(k-1)*DX):DY*i NET_NAME "upperCenter" "R0" "roman" 0.5)		
			PIN_ID~>term~>direction = "inputOutput"
			leAttachFig(LABEL_ID PIN_ID~>fig)						
		)	; for  	
		k = k+2
	)	; while

	k=2
	while(k<=X
		for(	 i 1 Y						
			sprintf(NET_NAME "MR<%d>" (i-1)*X+k)
			NET_ID=dbMakeNet(CELLVIEW NET_NAME)
			RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((1.69-0.115+(k-1)*DX):(DY*i-0.115) (1.69+0.115+(k-1)*DX):(DY*i+0.115)))
			dbAddFigToNet(RECT_ID NET_ID)
			PIN_ID=dbCreatePin(NET_ID RECT_ID)
			LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (1.69+(k-1)*DX):DY*i NET_NAME "upperCenter" "R0" "roman" 0.5)		
			PIN_ID~>term~>direction = "inputOutput"
			leAttachFig(LABEL_ID PIN_ID~>fig)						
		)	; for  	
		k = k+2
	)	; while
	
	; Guard Ring and Guard Ring Connections
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(0:-0.25 X*DX+1.205:-0.25 X*DX+1.205:Y*DY+1.78+0.75 -1.205:Y*DY+1.78+0.75 -1.205:0.5 ) ?netName "VSS")
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(-1.205:0.92 -1.205:-0.25 0.42:-0.25)  ?netName "VSS")

	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(0.26:DY 0.26:-0.25) 0.94)
	dbAddFigToNet(PATH_ID NET_ID_VSS)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(0.26:Y*DY+1.78 0.26:Y*DY+1.78+0.75) 0.94)
	dbAddFigToNet(PATH_ID NET_ID_VSS)

	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(-0.26+X*DX:DY -0.26+X*DX:-0.25) 0.94)
	dbAddFigToNet(PATH_ID NET_ID_VSS)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(-0.26+X*DX:Y*DY+1.78 -0.26+X*DX:Y*DY+1.78+0.75) 0.94)
	dbAddFigToNet(PATH_ID NET_ID_VSS)

	k=2
	while(k<X
		PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(k*DX:DY k*DX:-0.25)  1.46)
		dbAddFigToNet(PATH_ID NET_ID_VSS)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(k*DX:Y*DY+1.78 k*DX:Y*DY+1.78+0.75)  1.46)
		dbAddFigToNet(PATH_ID NET_ID_VSS)
		k=k+2
	)	;while

	
	dbSave(CELLVIEW)		; Save
	)	; prog	
) 	; procedure
