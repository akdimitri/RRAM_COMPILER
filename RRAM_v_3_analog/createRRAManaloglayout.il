;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			02/07/2021
; Description:	This file contains the main function SKILL code to create the RRAM Analog Part Layout
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAManaloglayout(					; LIST OF ARGUMENTS
									X 				; X SIZE OF ARRAY (COLS)
									Y				; Y SIZE OF ARRAY (ROWS)
									B				; B SIZE OF WORD
									LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
									NAME				; NAME OF THE CELLVIEW
									DB_RRAM_CELL		; DB OF RRAM
									DB_REF_CELL		; DB OF RRAM
									DB_PMUX_CELL		; DB OF RRAM
									DB_NMUX_CELL		; DB OF RRAM
									DX				; HORIZONTAL PITCH
									DY				; VERTICAL PITCH
								)



	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL			
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME			
			DB_RRAM_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			DB_REF_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF REF LAYOUT CELL
			DB_PMUX_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF PMUX LAYOUT CELL
			DB_NMUX_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF NMUX LAYOUT CELL
			NET_ID_VSS	; VARIABLE TO HOLD VSS NET ID
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB		
			TF_ID		; TECHNOLOGY ID		
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("Creating Layout.\n")
	
	; STEP 1
	; GENERATE LAYOUT VIEW
	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view	

	; STEP 2
	; PLACE RRAM ARRAY
	DB_RRAM_CELL_LAYOUT = dbOpenCellViewByType(DB_RRAM_CELL~>libName DB_RRAM_CELL~>cellName "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_RRAM_CELL_LAYOUT  "RRAM" list(0 -2.28) "R0")
	
	; STEP 3
	; PLACE REF ARRAY
	sprintf(NAME "REF_%d_%d" B Y)
	DB_REF_CELL_LAYOUT = dbOpenCellViewByType(DB_REF_CELL~>libName DB_REF_CELL~>cellName "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_REF_CELL_LAYOUT  NAME list(X*DX 0) "R0")

	; STEP 4
	; PLACE GUARD RING
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(-0.5:-3.03 (X+B)*DX+1.205+0.5:-2.53-0.5 (X+B)*DX+1.205+0.5:Y*DY+1.78+0.75-2.28+0.5 -1.205-0.5:Y*DY+1.78+0.75-2.28+0.5 -1.205-0.5:0.5-2.28+0.5 ) ?netName "VSS")
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(-1.205-0.5:0.92-2.28+0.5 -1.205-0.5:-0.25-2.28-0.5 0.42-0.5:-0.25-2.28-0.5)  ?netName "VSS")
	
	; STEP 4
	; PLACE PMUX
	sprintf(NAME "PMUX")
	DB_PMUX_CELL_LAYOUT = dbOpenCellViewByType(DB_PMUX_CELL~>libName DB_PMUX_CELL~>cellName "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_PMUX_CELL_LAYOUT  NAME list(2.5 -7.43-2*(X/B+1)*0.62-0.62-8) "R0")

	; STEP 6 
	; CREATE BUS FOR P_EN P_NOT_EN
	;Get the technology file id of the library that contains the definition of the via
	TF_ID=techGetTechFile(ddGetObj("tsmc18"))
	for(	j 1 ((X/B)+1)
		; P_EN
		sprintf(NET_NAME "P_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-(j-1)*0.62 -1.705+DX*(X+B):-7.43-(j-1)*0.62) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-(j-1)*0.62-0.115 -1.705+0.23:-7.43-(j-1)*0.62+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-(j-1)*0.62 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	

		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(0.835+(j-1)*DX*B-0.3 -7.43-(j-1)*0.62) "R0" 
                                         	list( 
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
		)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(0.835+(j-1)*DX*B:-7.43-(j-1)*0.62  0.835+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-8+2.26) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(0.835+(j-1)*DX*B -7.43-2*(X/B+1)*0.62-0.62-8+2.26+0.45) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(0.835-0.19+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-8+2.26 2.5+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-8+2.26) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)
		
		; P_NOT_EN
		sprintf(NET_NAME "P_NOT_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-(j-1)*0.62-(X/B+1)*0.62 -1.705+DX*(X+B):-7.43-(j-1)*0.62-(X/B+1)*0.62) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-(j-1)*0.62-0.115-(X/B+1)*0.62 -1.705+0.23:-7.43-(j-1)*0.62+0.115-(X/B+1)*0.62))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-(j-1)*0.62-(X/B+1)*0.62 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(2.5+(j-1)*DX*B-0.26 -7.43-(j-1)*0.62-(X/B+1)*0.62) "R0" 
                                         	list( 
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
		)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(2.5+(j-1)*DX*B:-7.43-(j-1)*0.62-(X/B+1)*0.62  2.5+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-8+4.985) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)


	)

	; STEP 7 
	; CONNECT P TO PMUX
	for( j 1 X+B
		sprintf(NET_NAME "P_<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL4" "drawing") list(3.375+(j-1)*DX:-1.330 3.375+(j-1)*DX:-5) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(3.375+(j-1)*DX:-5 3.375+(j-1)*DX:-7.43-2*(X/B+1)*0.62-0.62-8+3.95) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)
		VIA_ID=techFindViaDefByName(TF_ID "M4_M3")
		dbCreateVia( CELLVIEW VIA_ID list(3.375+(j-1)*DX -5) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)		
	)	; for
	; P PINS
	for(j 1 X
		if( modulo(j 2)==1
				then				
					sprintf(NET_NAME "P<%d>" j)	; 	Rows share P			
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "pin") list((0.39-0.14+(j-1)*DX):(0.02-0.14) (0.39+0.14+(j-1)*DX):(0.02+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (0.39+(j-1)*DX):0.02 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)				

				else					
					sprintf(NET_NAME "P<%d>" j)
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "pin") list((4.61-0.14+(j-1)*DX):(0.02-0.14) (4.61+0.14+(j-1)*DX):(0.02+0.14)))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (4.61+(j-1)*DX):0.02 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)						
					
		);if			
	)	; for j


	; STEP 8
	; GENERATE SEL PINS
	; PIN SEL<i>
	for( i 1 Y
		sprintf(NET_NAME "SEL<%d>" i)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(5-0.115:(i-1)*DY-0.115 5.115:(i-1)*DY+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 5:(i-1)*DY NET_NAME "upperCenter" "R0" "roman" 1.25)	
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
	)

	; STEP 9
	; GENERATE MR PINS
	k=1
	while(k<=X
		for(	 i 1 Y						
			sprintf(NET_NAME "MR<%d>" (i-1)*X+k)
			NET_ID=dbMakeNet(CELLVIEW NET_NAME)
			RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list((3.31-0.115+(k-1)*DX):(DY*(i-1)-0.115) (3.31+0.115+(k-1)*DX):(DY*(i-1)+0.115)))
			dbAddFigToNet(RECT_ID NET_ID)
			PIN_ID=dbCreatePin(NET_ID RECT_ID)
			LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (3.31+(k-1)*DX):DY*(i-1) NET_NAME "upperCenter" "R0" "roman" 1.25)		
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
			RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list((1.69-0.115+(k-1)*DX):(DY*(i-1)-0.115) (1.69+0.115+(k-1)*DX):(DY*(i-1)+0.115)))
			dbAddFigToNet(RECT_ID NET_ID)
			PIN_ID=dbCreatePin(NET_ID RECT_ID)
			LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (1.69+(k-1)*DX):DY*(i-1) NET_NAME "upperCenter" "R0" "roman" 1.25)		
			PIN_ID~>term~>direction = "inputOutput"
			leAttachFig(LABEL_ID PIN_ID~>fig)						
		)	; for  	
		k = k+2
	)	; while

	
	; STEP 10 
	; GENERATE PIN VSS
	; PIN VSS
	NET_ID_VSS=dbMakeNet(CELLVIEW "VSS")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:-0.115 0.115:0.115))
	dbAddFigToNet(RECT_ID NET_ID_VSS)
	PIN_ID=dbCreatePin(NET_ID_VSS RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:0 "VSS" "upperCenter" "R0" "roman" 1.25)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	


	; STEP 11
	; PLACE NMUX
	sprintf(NAME "NMUX")
	DB_NMUX_CELL_LAYOUT = dbOpenCellViewByType(DB_NMUX_CELL~>libName DB_NMUX_CELL~>cellName "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_NMUX_CELL_LAYOUT  NAME list(2.5 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-B*0.62-B*0.62-0.62-8) "R0")


	; STEP 11 
	; GENERATE BUS FOR N_EN NOT_N_EN
	for(	j 1 X/B
		;N_EN
		sprintf(NET_NAME "N_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62 -1.705+DX*(X+B):-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62-0.115 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	


		;N_NOT_EN
		sprintf(NET_NAME "N_NOT_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62-B*0.62 -1.705+DX*(X+B):-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62-B*0.62) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62-0.115-B*0.62 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62+0.115-B*0.62))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62-B*0.62 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	

	)	; for



	dbSave(CELLVIEW)		; Save
	return(CELLVIEW)	
	)	;prog
)	;PROCEDURE
