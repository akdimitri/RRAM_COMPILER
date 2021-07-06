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
									@optional
									(DB_SA_CELL dbOpenCellViewByType("THESIS" "SENSE_AMPLIFIER_LATCH_TYPE" "schematic" "" "r"))	; DB OF SA
									(DB_WR_CELL dbOpenCellViewByType("THESIS" "WRITE_AMPLIFIER" "schematic" "" "r"))	; DB OF WR
									(DB_TG dbOpenCellViewByType("THESIS" "TG" "schematic" "" "r"))		; DB OF TG
									(DB_TG5 dbOpenCellViewByType("THESIS" "TG5" "schematic" "" "r"))	; DB OF TG5
								)



	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL			
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME			
			DB_RRAM_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			DB_REF_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF REF LAYOUT CELL
			DB_PMUX_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF PMUX LAYOUT CELL
			DB_NMUX_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF NMUX LAYOUT CELL
			DB_WR_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF WR LAYOUT CELL
			DB_TG_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF 1.8V TG
			DB_TG5_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF 5V TG
			DB_MUX_BLOCK			; TEMPORARY VARIABLE TO HOLD DB OF MUX BLOCK
			DB_SA_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF MUX BLOCK
			NET_ID_VSS	; VARIABLE TO HOLD VSS NET ID
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB		
			TF_ID		; TECHNOLOGY ID		
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("Creating Layout.\n")

	if(	X*DX<35*B then
		printf("CHOOSE A LARGER ARRAY IN ORDER TO USE THIS BIT WORD\n")
		return(nil)
	)
	
	; STEP 1
	; GENERATE LAYOUT VIEW
	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view	

	; STEP 2
	; PLACE RRAM ARRAY
	DB_RRAM_CELL_LAYOUT = dbOpenCellViewByType(DB_RRAM_CELL~>libName DB_RRAM_CELL~>cellName "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_RRAM_CELL_LAYOUT  "RRAM" list(0 -2.28) "R0")
	
	; STEP 3
	; PLACE REF ARRAY
	sprintf(NAME "REF")
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
		sprintf(NET_NAME "P<%d>" j)
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
	dbCreateInst(CELLVIEW DB_NMUX_CELL_LAYOUT  NAME list(2.5 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-X/B*0.62-0.62-8) "R0")


	; STEP 11 
	; GENERATE BUS FOR N_EN NOT_N_EN
	for(	j 1 X/B
		;N_EN_BUS
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
		; N_EN_TO NMUX		
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(0.835+(j-1)*DX*B-0.3 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62) "R0" 
                                         	list( 
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
		)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(0.835+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-(j-1)*0.62  
								0.835+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62*2-0.62-8+2.26) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(0.835+(j-1)*DX*B -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62*2-0.62-8+2.26+0.45) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(0.835-0.19+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62*2-0.62-8+2.26
	 																2.5+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62*2-0.62-8+2.26) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)



		;N_NOT_EN
		sprintf(NET_NAME "N_NOT_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-(j-1)*0.62 -1.705+DX*(X+B):-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-(j-1)*0.62 ) 0.3)
		dbAddFigToNet(PATH_ID NET_ID)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-(j-1)*0.62-0.115 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-(j-1)*0.62+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-(j-1)*0.62 NET_NAME "upperCenter" "R0" "roman" 1)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
		; N_NOT_EN TO NMUX
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(2.5+(j-1)*DX*B-0.26 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-(j-1)*0.62) "R0" 
                                         	list( 
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
		)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(2.5+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-X/B*0.62-(j-1)*0.62  
																	2.5+(j-1)*DX*B:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-(j-1)*0.62-0.62-3.01) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
								
		
	

	)	; for


	
	; STEP 12 
	; CONNECT N TO NMUX
	for( j 1 X
		sprintf(NET_NAME "N<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(3.375+(j-1)*DX-1:-1.330 3.375+(j-1)*DX-1:-5) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL5" "drawing") list(3.375+(j-1)*DX-1:-5 3.375+(j-1)*DX-1:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-8+3.935) 0.44)
		dbAddFigToNet(PATH_ID NET_ID)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL5" "drawing") list(3.375+(j-1)*DX-1.22:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-8+3.935
																	3.375+(j-1)*DX+0.27:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-8+3.935) 0.44)
		dbAddFigToNet(PATH_ID NET_ID)
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(3.375+(j-1)*DX-1 -5) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)		
		VIA_ID=techFindViaDefByName(TF_ID "M4_M3")
		dbCreateVia( CELLVIEW VIA_ID list(3.375+(j-1)*DX-1 -5) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)	
		VIA_ID=techFindViaDefByName(TF_ID "M5_M4")
		dbCreateVia( CELLVIEW VIA_ID list(3.375+(j-1)*DX-1 -5) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
		VIA_ID=techFindViaDefByName(TF_ID "M4_M3")
		dbCreateVia( CELLVIEW VIA_ID list(3.375+(j-1)*DX -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-8+3.5) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)	
		VIA_ID=techFindViaDefByName(TF_ID "M5_M4")
		dbCreateVia( CELLVIEW VIA_ID list(3.375+(j-1)*DX -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-8+3.5) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
		
	)	; for

	; STEP 13
	; PLACE WRITE AMPLIFIER
	DB_WR_CELL_LAYOUT = dbOpenCellViewByType(DB_WR_CELL~>libName DB_WR_CELL~>cellName "layout" "maskLayout" "r")
	for( j 1 B			; COLS
			
			; PLACE (j,i)
			;printf("Placing CELL (WR<%d>)\n" j)
			sprintf(INST_NAME "WR<%d>" j)
			dbCreateInst(CELLVIEW DB_WR_CELL_LAYOUT INST_NAME list((j-1)*(26.54+4.23*2)+1.645
					-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16 ) "R0" 1)
	)	; for

	; STEP 14
	; PLACE WR_OUT_SW<1:B>
	; 		WR_P_SW<1:B>
	; 		WR_N_SW<1:B>
	DB_TG_CELL_LAYOUT = dbOpenCellViewByType(DB_TG~>libName DB_TG~>cellName "layout" "maskLayout" "r")
	for( j 1 B			; COLS
		
		; PLACE (j,i)
		;printf("Placing CELL (WR_OUT_SW<%d>)\n" j)
		sprintf(INST_NAME "WR_OUT_SW<%d>" j)
		dbCreateInst(CELLVIEW DB_TG_CELL_LAYOUT INST_NAME list((j-1)*(26.54+4.23*2)+9.87+3.29/2
				-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+8 ) "MX" 1)
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+9.87+3.29/2-0.75
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.065) "R0" 
										list(                                          	
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
		sprintf(NET_NAME "WR_IN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list((j-1)*(26.54+4.23*2)+10.015+3.29/2-0.895:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.375
																	(j-1)*(26.54+4.23*2)+1.645:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.375 ) 0.28)
		dbAddFigToNet(PATH_ID NET_ID)	
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+1.645
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.065) "R0" 
										list(                                          	
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
		; VIA FOR WRITE_L
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+9.87+3.29/2
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.825) "R0" 
										list(                                          	
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
		; VIA FOR NOT_WRITE_L
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+9.87+3.29/2
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+2.795) "R0" 
										list(                                          	
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 1)               ;column                                             	
										)
		)
	)	; for
	; WRITE_L
	sprintf(NET_NAME "WRITE_L")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.825+0.45+0.14
																(B-1)*(26.54+4.23*2)+9.87+3.29/2+0.19:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.825+0.45+0.14 ) 0.28)
	dbAddFigToNet(PATH_ID NET_ID)	
	;WRITE_L PIN
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.825+0.45+0.14-0.115
														 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.825+0.45+0.14+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+5.825+0.45+0.14 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	; NOT_WRITE_L	
	sprintf(NET_NAME "NOT_WRITE_L")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+2.795-0.45-0.14
																(B-1)*(26.54+4.23*2)+9.87+3.29/2+0.19:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+2.795-0.45-0.14 ) 0.28)
	dbAddFigToNet(PATH_ID NET_ID)	
	;NOT_WRITE_L PIN
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+2.795-0.45-0.14-0.115
														 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+2.795-0.45-0.14+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+2.795-0.45-0.14 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	



	DB_TG5_CELL_LAYOUT = dbOpenCellViewByType(DB_TG5~>libName DB_TG5~>cellName "layout" "maskLayout" "r")
	for( j 1 B			; COLS
			
			; PLACE (j,i)
			;printf("Placing CELL (WR_P_SW<%d>)\n" j)
			sprintf(INST_NAME "WR_P_SW<%d>" j)
			dbCreateInst(CELLVIEW DB_TG5_CELL_LAYOUT INST_NAME list((j-1)*(26.54+4.23*2)+26.54+2.115
					-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16+8 ) "R0" 1)

			;WR_P<1:B>
			sprintf(NET_NAME "WR_P<%d>" j)
			NET_ID =dbMakeNet(CELLVIEW NET_NAME)
			PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list((j-1)*(26.54+4.23*2)+26.54-7.185-0.56-1.54:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+2.755
																(j-1)*(26.54+4.23*2)+26.54+1.43:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+2.755 ) 0.28)
			dbAddFigToNet(PATH_ID NET_ID)	
			; VIA FOR WR_P<1:B>
			VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
			dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54-7.185+0.335-0.56-1.54
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+2.755) "R0" 
										list(                                          	
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
			)
			VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
			dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54+0.98
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+2.755) "R0" 
										list(                                          	
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
			)	
	)	; for
	for( j 1 B			; COLS
			
			; PLACE (j,i)
			;printf("Placing CELL (WR_N_SW<%d>)\n" j)
			sprintf(INST_NAME "WR_N_SW<%d>" j)
			dbCreateInst(CELLVIEW DB_TG5_CELL_LAYOUT INST_NAME list((j-1)*(26.54+4.23*2)+26.54+2.115*3
					-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16 +8) "R0" 1)
			;WR_N<1:B>
			sprintf(NET_NAME "WR_N<%d>" j)
			NET_ID =dbMakeNet(CELLVIEW NET_NAME)
			PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list((j-1)*(26.54+4.23*2)+26.54-2.02-0.56-1.54:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+3.6
																(j-1)*(26.54+4.23*2)+26.54+5.775:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+3.6 ) 0.28)
			dbAddFigToNet(PATH_ID NET_ID)	
			; VIA FOR WR_N<1:B>
			VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
			dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54-2.02+0.34-0.56-1.54
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+3.6) "R0" 
										list(                                          	
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
			)
			VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
			dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54+5.775-0.335
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+3.6) "R0" 
										list(                                          	
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
			)
	)	; for

	; NOT_WRITE_H
	for(j 1 B
		dbAddFigToNet(PATH_ID NET_ID)	
		; VIA FOR NOT_WRITE_H
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54+2.115
									-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+4.985) "R0" 
									list(                                          	
									list("cutRows" 2)             ;row
                                     	list("cutColumns" 1)               ;column                                             	
									)
		)	
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54+2.115+4.23
									-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+4.985) "R0" 
									list(                                          	
									list("cutRows" 2)             ;row
                                     	list("cutColumns" 1)               ;column                                             	
									)
		)	
	)
	; NOT_WRITE_H	
	sprintf(NET_NAME "NOT_WRITE_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+5.575
																(B-1)*(26.54+4.23*2)+26.54+2.115+4.42:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+5.575) 0.28)
	dbAddFigToNet(PATH_ID NET_ID)	
	;NOT_WRITE_H PIN
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+5.575-0.115
														 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+5.575+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+5.575 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	

	; WRITE_H
	for(j 1 B
		dbAddFigToNet(PATH_ID NET_ID)	
		; VIA FOR WRITE_H
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54+2.115
									-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+2.265) "R0" 
									list(                                          	
									list("cutRows" 2)             ;row
                                     	list("cutColumns" 1)               ;column                                             	
									)
		)	
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+26.54+2.115+4.23
									-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+2.265) "R0" 
									list(                                          	
									list("cutRows" 2)             ;row
                                     	list("cutColumns" 1)               ;column                                             	
									)
		)	
	)
	; WRITE_H	
	sprintf(NET_NAME "WRITE_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+1.675
																(B-1)*(26.54+4.23*2)+26.54+2.115+4.42:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+1.675) 0.28)
	dbAddFigToNet(PATH_ID NET_ID)	
	;NOT_WRITE_H PIN
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+1.675-0.115
														 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+1.675+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+1.675 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	


	;P_OUT<1:B>	
	for( j 1 B
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+29.225
										 -7.43-2*(X/B+1)*0.62-0.62-16-1-(j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+29.225
										 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+6.64) "R0" 
	                                         	list( 
											list("cutRows" 2)             ;row
	                                         	list("cutColumns" 1)               ;column                                             	
											)
		)
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+29.225
										 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+6.64) "R0" 
	                                         	list( 
											list("cutRows" 2)             ;row
	                                         	list("cutColumns" 1)               ;column                                             	
											)
		)
		sprintf(NET_NAME "P_OUT<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list((j-1)*(26.54+4.23*2)+29.225:-7.43-2*(X/B+1)*0.62-0.62-16-1-(j-1)*0.62
																	(j-1)*(26.54+4.23*2)+29.225:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+6.64) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
	)

	;N_OUT<1:B>	
	for( j 1 B
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+29.225+4.23
										 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-(j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+29.225+4.23
										 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+6.64) "R0" 
	                                         	list( 
											list("cutRows" 2)             ;row
	                                         	list("cutColumns" 1)               ;column                                             	
											)
		)
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list((j-1)*(26.54+4.23*2)+29.225+4.23
										 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+6.64) "R0" 
	                                         	list( 
											list("cutRows" 2)             ;row
	                                         	list("cutColumns" 1)               ;column                                             	
											)
		)
		sprintf(NET_NAME "N_OUT<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list((j-1)*(26.54+4.23*2)+29.225+4.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-(j-1)*0.62
																	(j-1)*(26.54+4.23*2)+29.225+4.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+6.64) 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
	)
	
	; STEP 15 
	; GENERATE PIN VDD High 5 V
	; PIN VDD
	NET_ID=dbMakeNet(CELLVIEW "VDD")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-0.115 
															0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62 "VDD" "upperCenter" "R0" "roman" 1.25)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	; STEP 16 
	; GENERATE PIN VDDW 1.8-5 V
	; PIN VDDW
	NET_ID=dbMakeNet(CELLVIEW "VDDW")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-0.115 
															0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62 "VDDW" "upperCenter" "R0" "roman" 1.25)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	; STEP 17
	; FILL THE GAPS MPP
	for( j 1 B
	CCSdrawMPPUsingTemplate("NWellGuardring" ?cvId CELLVIEW ?pts list(
						(j-1)*(26.54+4.23*2)+26.54:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16
						(j-1)*(26.54+4.23*2)+26.54+7.75:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16)  
						?netName "VDDL")
	sprintf(NET_NAME "VDDL")	
	PATH_ID= dbCreatePath(CELLVIEW list("DIFF" "drawing") list((j-1)*(26.54+4.23*2)+26.54+7.75:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16
															(j-1)*(26.54+4.23*2)+26.54+8.25+0.7-0.28:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16) 0.42)
	PATH_ID= dbCreatePath(CELLVIEW list("NIMP" "drawing") list((j-1)*(26.54+4.23*2)+26.54+7.75:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16
															(j-1)*(26.54+4.23*2)+26.54+8.25+0.7-0.1:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16) 0.78)
	
	PATH_ID= dbCreatePath(CELLVIEW list("NWELL" "drawing") list((j-1)*(26.54+4.23*2)+26.54:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16
															(j-1)*(26.54+4.23*2)+26.54+8.25+0.7:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16) 0.98)
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list((j-1)*(26.54+4.23*2)+26.54+7.75:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16
															(j-1)*(26.54+4.23*2)+26.54+8.29+0.7-0.36:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16) 0.34)
		
	dbAddFigToNet(PATH_ID NET_ID)
	)

	; STEP 18
	; PLACE MUXES FOR SENSE ARRAY
	; CREATE P BUSES FOR CELLS AND REFS
	for(j 1 B
		sprintf(NET_NAME "P_OUT<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		; Vertical
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") 
						list(
						(j-1)*(26.54+4.23*2)+29.225:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8+6.64
						(j-1)*(26.54+4.23*2)+29.225:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62
						)
						 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
		;Horizontal
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") 
						list(	
						0:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62		
						(B-1)*(26.54+4.23*2)+29.225:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62
						)
						 0.3)
		dbAddFigToNet(PATH_ID NET_ID)	
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										(j-1)*(26.54+4.23*2)+29.225-0.45+0.19
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		
	)

	for(j B+1 2*B
		sprintf(NET_NAME "P_OUT<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		; Vertical
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") 
						list(
						X*DX+(j-1-B)*DX-0.875+2.5:-7.43-2*(X/B+1)*0.62-0.62-16-2.745
						X*DX+(j-1-B)*DX-0.875+2.5:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62
						)
						 0.3)
		dbAddFigToNet(PATH_ID NET_ID)	
		;Horizontal
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") 
						list(	
						0:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62		
						(X+B)*DX-3.375:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62
						)
						 0.3)
		dbAddFigToNet(PATH_ID NET_ID)	
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										X*DX+(j-1-B)*DX-0.875+2.5-0.45+0.15
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		
	)
	
	; PLACE MUX BLOCK FOR SENSE ARRAYS
	sprintf(NAME "MUX_BLOCK_%d" B)
	DB_MUX_BLOCK = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_MUX_BLOCK  "MUX_BLOCK<1>" list(2.5 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8) "R0")
	; PLACE MUX BLOCK FOR SENSE ARRAYS
	sprintf(NAME "MUX_BLOCK_%d" B)
	DB_MUX_BLOCK = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_MUX_BLOCK "MUX_BLOCK<2>" list(2.5+B*DX -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8) "R0")
	
	for(j 1 2*B
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										1.625+(j-1)*DX
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+3.5) "R0" 
	                                         	list( 
											list("cutRows" 2)             ;row
	                                         	list("cutColumns" 1)               ;column                                             	
											)
		)
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list(
										1.625+(j-1)*DX
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+3.5) "R0" 
	                                         	list( 
											list("cutRows" 2)             ;row
	                                         	list("cutColumns" 1)               ;column                                             	
											)
		)
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										1.625+(j-1)*DX-0.45
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		sprintf(NET_NAME "P_OUT<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		; Vertical
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") 
						list(
						1.625+(j-1)*DX:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-(j-1)*0.62+0.19
						1.625+(j-1)*DX:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+3.5
						)
						 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
		
	)

	; NOT_READ 1.8 V	
	sprintf(NET_NAME "NOT_READ")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+4.725
																2*B*DX+2.5-DX:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+4.725)	0.38)
	dbAddFigToNet(PATH_ID NET_ID)	
	;NOT_READ 1.8V
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+4.725-0.115
														 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+4.725+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+4.725 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	; READ 1.8 V	
	sprintf(NET_NAME "READ")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+2.265
																2*B*DX+2.5-DX:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+2.265)	0.38)
	dbAddFigToNet(PATH_ID NET_ID)	
	; READ 1.8V
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(-1.705:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+2.265-0.115
														 -1.705+0.23:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+2.265+0.115))
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") -1.705+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8+2.265 NET_NAME "upperCenter" "R0" "roman" 1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	


	for(j 1 2*B
		sprintf(NET_NAME "SA_IN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		; Vertical
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") 
						list(
						3.375+(j-1)*DX:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-8-1.32
						3.375+(j-1)*DX:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(j-1)*0.62
						)
						 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
		
		; Horizontal
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") 
						list(
						0:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(j-1)*0.62
						B*15:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(j-1)*0.62
						)
						 0.3)
		dbAddFigToNet(PATH_ID NET_ID)		
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										3.375+(j-1)*DX
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)	
	)
	
	;------------------------------------------------
	; --- TODO - PARAMETERISATION FOR OTHER SAs
	;------------------------------------------------
	;STEP 19
	; PLACE SENSE ARRAY
	for(j 1 B
		; PLACE MUX BLOCK FOR SENSE ARRAYS
		sprintf(NAME "SA<%d>" j)
		DB_SA_CELL_LAYOUT = dbOpenCellViewByType(DB_SA_CELL~>libName DB_SA_CELL~>cellName "layout" "maskLayout" "r")
		dbCreateInst(CELLVIEW DB_SA_CELL_LAYOUT  NAME list((j-1)*15+5.405 -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1) "MX")
	
	)
	; CONNECT SA_IN
	for(j 1 B
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										1.595+(j-1)*15
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		sprintf(NET_NAME "SA_IN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		; Vertical
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") 
						list(
						1.595+(j-1)*15:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(j-1)*0.62
						1.595+(j-1)*15:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-1.115
						)
						 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										1.595+(j-1)*15
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-1.115) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list(
										1.595+(j-1)*15
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-1.115) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
	)

	for(j 1 B
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										9.725+(j-1)*15
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(B+j-1)*0.62) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		sprintf(NET_NAME "SA_IN<%d>" j+B)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		; Vertical
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") 
						list(
						9.985+(j-1)*15:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-(j-1)*0.62-B*0.62
						9.985+(j-1)*15:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-1.115-0.19
						)
						 0.38)
		dbAddFigToNet(PATH_ID NET_ID)	
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(
										9.985+(j-1)*15-0.45+0.015
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-1.115) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
		VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
		dbCreateVia( CELLVIEW VIA_ID list(
										9.985+(j-1)*15-0.45+0.015
										-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-1.115) "R0" 
	                                         	list( 
											list("cutRows" 1)             ;row
	                                         	list("cutColumns" 2)               ;column                                             	
											)
		)
	)
	
	

	dbSave(CELLVIEW)		; Save
	return(CELLVIEW)	
	)	;prog
)	;PROCEDURE
