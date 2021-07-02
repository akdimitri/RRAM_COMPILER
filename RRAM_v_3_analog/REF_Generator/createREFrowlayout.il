;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			02/07/2021
; Description:	This file contains the SKILL to create the layout of a ROW of a REF
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createREFrowlayout(
												; LIST OF ARGUMENTS
								B 				; B SIZE OF ARRAY (COLS)
								LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
								NAME				; NAME OF THE CELLVIEW
								DB_REF_CELL		; DB OF REF CELL
								DX				; HORIZONTAL PITCH

							) 	; END OF LIST OF ARGUMENTS

	prog(	(	; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL			
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME			
			DB_REF_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF REF LAYOUT CELL			
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB
			)			; END OF LIST OF LOCAL VARIABLES

	printf("Creating Layout for 1 ROW of REF.\n")

	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view
	DB_REF_CELL_LAYOUT = dbOpenCellViewByType(DB_REF_CELL~>libName DB_REF_CELL~>cellName "layout" "maskLayout" "r")

		for( j 1 B			; COLS
			
			; PLACE (j,i)
			printf("Placing CELL (M<%d>)\n" j)
			sprintf(INST_NAME "M<%d>" j)

			if( (modulo(j 2)==1) 
				then
				dbCreateInst(CELLVIEW DB_REF_CELL_LAYOUT INST_NAME list(j*DX 0) "R90" 1)
				else
				dbCreateInst(CELLVIEW DB_REF_CELL_LAYOUT INST_NAME list((j-1)*DX 0) "MXR90" 1)		; j-1 be careful the mirroring
			)	; then
			
			
			; CREATE LABEL/PINS SEL
			if(	(j==1) then
				NET_ID=dbMakeNet(CELLVIEW "SEL")
				RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(2.385:0.64 2.615:0.87))
				dbAddFigToNet(RECT_ID NET_ID)
				PIN_ID=dbCreatePin(NET_ID RECT_ID)
				LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 2.5:0.755 "SEL" "upperCenter" "R0" "roman" 0.5)	
				PIN_ID~>term~>direction = "input"
				leAttachFig(LABEL_ID PIN_ID~>fig)				
			)	;then
			
			
			
			if( modulo(j 2)==1
				then		
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N		
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((-0.115+(j-1)*DX):-0.115 (0.115+(j-1)*DX):0.115))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") ((j-1)*DX):0 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)		
			
					sprintf(NET_NAME "P<%d>" j)	; 	Rows share P			
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((4.38-0.14+(j-1)*DX):-0.14 (4.38+0.14+(j-1)*DX):0.14))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (4.38+(j-1)*DX):0 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)						
					
				else
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((-0.115+j*DX):-0.115 (0.115+j*DX):0.115))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (j*DX):0 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
					
					sprintf(NET_NAME "P<%d>" j)
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((5.62-0.14+(j-2)*DX):-0.14 (5.62+0.14+(j-2)*DX):0.14))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (5.62+(j-2)*DX):0 NET_NAME "upperCenter" "R0" "roman" 0.5)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)						
					
			);if		
		)	; for j
	
	dbSave(CELLVIEW)		; Save
			

	) ; prog
) ; procedure
