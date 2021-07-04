;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			03/07/2021
; Description:	This file contains the SKILL to create the layout of a MUX BLOCK
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createMUXblocklayout(		B 				; B SIZE OF ARRAY (COLS)
									LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
									NAME				; NAME OF THE CELLVIEW
									DX				; HORIZONTAL PITCH
									@optional
									(DB_MUX_SWITCH_CELL_LAYOUT	dbOpenCellViewByType("THESIS" "MUX_SWITCH" "layout")); DB OF LAYOUT OF MUX_SWITCH CELL
								)


						
	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL			
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME			
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB		
			PATH_ID		; TEMPORARY VARIABLE TO HOLD PATH DB	
			)			; END OF LIST OF LOCAL VARIABLES




	printf("Creating Layout.\n")
	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view

	; Create PATHS
	; NOT_EN
	sprintf(NET_NAME "NOT_EN")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(0:4.725 (B-1)*DX:4.725) 0.38)
	dbAddFigToNet(PATH_ID NET_ID)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-0.115:4.985-0.115 0.115:4.985+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") 0:4.985 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	; EN
	sprintf(NET_NAME "EN")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(0:2.265 (B-1)*DX:2.265) 0.38)
	dbAddFigToNet(PATH_ID NET_ID)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-0.115:2.26-0.115 0.115:2.26+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") 0:2.26 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	; VSS	
	NET_ID=dbMakeNet(CELLVIEW "VSS")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:-0.115 0.115:0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:0 "VSS" "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	; VDD	
	NET_ID=dbMakeNet(CELLVIEW "VDD")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:8-0.115 0.115:8+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:8 "VDD" "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
		

	for( j 1 B			; COLS
		; PLACE (j,i)
		printf("Placing CELL (M<%d>)\n" j)
		sprintf(INST_NAME "M<%d>" j)
		dbCreateInst(CELLVIEW DB_MUX_SWITCH_CELL_LAYOUT INST_NAME list((j-1)*DX 0) "R0" 1)
		; BL	
		sprintf(NET_NAME "BL<%d>" j)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115+0.57+(j-1)*DX:-0.115+3.245 0.115+0.57+(j-1)*DX:0.115+3.245))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0.57+(j-1)*DX:3.245 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "inputOutput"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
		; OUT
		sprintf(NET_NAME "OUT<%d>" j)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115-0.57+(j-1)*DX:-0.115+3.245 0.115-0.57+(j-1)*DX:0.115+3.245))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") -0.57+(j-1)*DX:3.245 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "inputOutput"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
	)









	dbSave(CELLVIEW)		; Save
	)	; prog
)	;	procedure
