;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			04/07/2021
; Description:	This file contains the SKILL to create the layout of a MUX
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( createMUXlayout(		B 				; B SIZE OF WORD
								X 				; B SIZE OF ARRAY (COLS)
								LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
								NAME				; NAME OF THE CELLVIEW
								DX				; HORIZONTAL PITCH of BLOCK									
								DB_MUX_BLOCK_LAYOUT	; DB OF LAYOUT OF MUX_BLOCK CELL
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
			TF_ID		; TECHNOLOGY ID
			VIA_ID		; TEMPORARY VARIABLE TO HOLD VIA DB
			)	

	printf("Creating Layout for MUX.\n")
	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view


	for( j 1 X/B			; COLS
		; PLACE (j,i)
		printf("Placing CELL (M<%d>)\n" j)
		sprintf(INST_NAME "M<%d>" j)
		dbCreateInst(CELLVIEW DB_MUX_BLOCK_LAYOUT INST_NAME list((j-1)*DX*B 0) "R0" 1)
		; NOT_EN	
		sprintf(NET_NAME "NOT_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)		
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-0.115+(j-1)*DX*B:4.985-0.115 0.115+(j-1)*DX*B:4.985+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") (j-1)*DX*B:4.985 NET_NAME "upperCenter" "R0" "roman" 1.25)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
		; EN	
		sprintf(NET_NAME "EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)		
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-0.115+(j-1)*DX*B:2.26-0.115 0.115+(j-1)*DX*B:2.26+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") (j-1)*DX*B:2.26 NET_NAME "upperCenter" "R0" "roman" 1.25)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)			
	)

	; VSS	
	NET_ID=dbMakeNet(CELLVIEW "VSS")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:-0.115 0.115:0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:0 "VSS" "upperCenter" "R0" "roman" 1.25)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	; VDD	
	NET_ID=dbMakeNet(CELLVIEW "VDD")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:8-0.115 0.115:8+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:8 "VDD" "upperCenter" "R0" "roman" 1.25)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	for( j 1 X
		; BL	
		sprintf(NET_NAME "BL<%d>" j)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115+0.57+(j-1)*DX:-0.115+3.245 0.115+0.57+(j-1)*DX:0.115+3.245))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0.57+(j-1)*DX:3.245 NET_NAME "upperCenter" "R0" "roman" 1.25)		
		PIN_ID~>term~>direction = "inputOutput"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
	)

	;Get the technology file id of the library that contains the definition of the via
	TF_ID=techGetTechFile(ddGetObj("tsmc18"))

	;Get the id of the via you want to place
	

	for( j 1 B
		sprintf(NET_NAME "OUT<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-0.57:-9-(j-1)*0.62 DX*(X-1)-0.57:-9-(j-1)*0.62) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-0.115-0.455:-0.115-9-(j-1)*0.62 0.115-0.455:0.115-9-(j-1)*0.62))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -0.455:-9-(j-1)*0.62 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "inputOutput"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
		
		for( i 1 X/B
			;printf("Placing VIA at %L:%L\n" (-0.875+(j-1)*B+(i-1)*DX) 3.5)
			VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
			dbCreateVia( CELLVIEW VIA_ID list(-0.875+(j-1)*DX+(i-1)*DX*B 3.5) "R0" 
                                             	list( 
											list("cutRows" 2)             ;row
                                             	list("cutColumns" 1)               ;column
                                             	;list("cutSpacing" list(x y))       ; cut spacing for x and y
                                             	;list("layer1Enc" list(x y))         ; enclosure for layer1
                                             	;list("layer2Enc" list(x y))         ; enclosure for layer2
                                             	;list("cutWidth" 0.2)                 ; cut width
                                             	;list("cutHeight" 0.4)                ;cut height
                                             	;list("originOffset" list(x y))      ; justification
											)
			)
			VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
			dbCreateVia( CELLVIEW VIA_ID list(-0.875+(j-1)*DX+(i-1)*DX*B 3.5) "R0" 
                                             	list( 
											list("cutRows" 2)             ;row
                                             	list("cutColumns" 1)               ;column
                                             	;list("cutSpacing" list(x y))       ; cut spacing for x and y
                                             	;list("layer1Enc" list(x y))         ; enclosure for layer1
                                             	;list("layer2Enc" list(x y))         ; enclosure for layer2
                                             	;list("cutWidth" 0.2)                 ; cut width
                                             	;list("cutHeight" 0.4)                ;cut height
                                             	;list("originOffset" list(x y))      ; justification
											)
			)

			VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
			dbCreateVia( CELLVIEW VIA_ID list(-0.615+(j-1)*DX+(i-1)*DX*B -9-(j-1)*0.62) "R0" 
                                             	list( 
											list("cutRows" 1)             ;row
                                             	list("cutColumns" 2)               ;column
                                             	;list("cutSpacing" list(x y))       ; cut spacing for x and y
                                             	;list("layer1Enc" list(x y))         ; enclosure for layer1
                                             	;list("layer2Enc" list(x y))         ; enclosure for layer2
                                             	;list("cutWidth" 0.2)                 ; cut width
                                             	;list("cutHeight" 0.4)                ;cut height
                                             	;list("originOffset" list(x y))      ; justification
											)
			)

			PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(-0.875+(j-1)*DX+(i-1)*DX*B:3.5 -0.875+(j-1)*DX+(i-1)*DX*B:-9-(j-1)*0.62) 0.3)
			dbAddFigToNet(PATH_ID NET_ID)

			

		)	; for
	)	; for 
	dbSave(CELLVIEW)		; Save
	return(CELLVIEW)	
	)	; prog
)	; procedure
