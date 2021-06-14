;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			28/02/2021
; Description:	This file contains the SKILL to create the layout of a ROW of a RRAM
; Version:		2
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAMrowlayout(					; LIST OF ARGUMENTS
								X 				; X SIZE OF ARRAY (COLS)
								LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
								NAME				; NAME OF THE CELLVIEW
								DB_RRAM_CELL		; DB OF RRAM CELL
								DX				; HORIZONTAL PITCH
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
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("Creating Layout.\n")

	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view
	;TF = techGetTechFile(CELLVIEW)	; read technology file
	DB_RRAM_CELL_LAYOUT = dbOpenCellViewByType(DB_RRAM_CELL~>libName DB_RRAM_CELL~>cellName "layout" "maskLayout" "r")

	for( j 1 X			; COLS
			
			; PLACE (j,i)
			printf("Placing CELL (M<%d>)\n" j)
			sprintf(INST_NAME "M<%d>" j)

			if( (modulo(j 2)==1) 
				then
				dbCreateInst(CELLVIEW DB_RRAM_CELL_LAYOUT INST_NAME list(j*DX 0) "R90" 1)
				else
				dbCreateInst(CELLVIEW DB_RRAM_CELL_LAYOUT INST_NAME list((j-1)*DX 0) "MXR90" 1)		; j-1 be careful the mirroring
			)	; then
			
			
			; CREATE LABEL/PINS VSS/SEL
			if(	j==1
				then
				NET_ID_VSS=dbMakeNet(CELLVIEW "VSS")
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(-0.115:2.165 0.115:2.395))
				dbAddFigToNet(RECT_ID NET_ID_VSS)
				PIN_ID=dbCreatePin(NET_ID_VSS RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:2.28 "VSS" "upperCenter" "R0" "roman" 0.5)		
				PIN_ID~>term~>direction = "inputOutput"
				leAttachFig(LABEL_ID PIN_ID~>fig)		

				NET_ID=dbMakeNet(CELLVIEW "SEL")
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(4.885:2.165 5.115:2.395))
				dbAddFigToNet(RECT_ID NET_ID)
				PIN_ID=dbCreatePin(NET_ID RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") DX:2.28 "SEL" "upperCenter" "R0" "roman" 0.5)	
				PIN_ID~>term~>direction = "input"
				leAttachFig(LABEL_ID PIN_ID~>fig)				
			)	;then
			
			
			
			if( modulo(j 2)==1
				then		
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N		
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((2.77-0.115+(j-1)*DX):(1.14-0.115) (2.77+0.115+(j-1)*DX):(1.14+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (2.77+(j-1)*DX):1.14 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)		
			
					sprintf(NET_NAME "P<%d>" j)	; 	Rows share P			
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((0.39-0.14+(j-1)*DX):(2.3-0.14) (0.39+0.14+(j-1)*DX):(2.3+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (0.39+(j-1)*DX):2.3 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
					
					sprintf(NET_NAME "MR<%d>" j)
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((3.31-0.115+(j-1)*DX):(2.28-0.115) (3.31+0.115+(j-1)*DX):(2.28+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (3.31+(j-1)*DX):2.28 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	

				else
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((2.23-0.115+(j-1)*DX):(1.14-0.115) (2.23+0.115+(j-1)*DX):(1.14+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (2.23+(j-1)*DX):1.14 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
					
					sprintf(NET_NAME "P<%d>" j)
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((4.61-0.14+(j-1)*DX):(2.3-0.14) (4.61+0.14+(j-1)*DX):(2.3+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (4.61+(j-1)*DX):2.3 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
					
					sprintf(NET_NAME "MR<%d>" j)
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((1.69-0.115+(j-1)*DX):(2.28-0.115) (1.69+0.115+(j-1)*DX):(2.28+0.115)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (1.69+(j-1)*DX):2.28 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
			);if			
		)	; for j
	
	dbSave(CELLVIEW)		; Save
	)	; prog	
) 	; procedure
