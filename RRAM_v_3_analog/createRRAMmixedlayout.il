;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			27/07/2021
; Description:	This file contains the main function SKILL code to create the RRAM Analog Part Layout
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAMmixedlayout(					; LIST OF ARGUMENTS
									X 				; X SIZE OF ARRAY (COLS)
									Y				; Y SIZE OF ARRAY (ROWS)
									B				; B SIZE OF WORD
									LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
									NAME				; NAME OF THE CELLVIEW
									DB_ANALOG		; DB OF ANALOG RRAM
									DB_CONTROLLER	; DB OF CONTROLLER
									DB_SIGNALS		; DB OF SIGNALS
									@optional		
									(DB_LEVEL_DOWN_LAYOUT	dbOpenCellViewByType("THESIS" "LEVEL_DOWN_SIGNALS" "layout" "" "r")	)									
								)

	
	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL			
			DB_ANALOG_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			DB_CONTROLLER_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			DB_PIN			
			TERM
			NET_ID_VSS	; VARIABLE TO HOLD VSS NET ID
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB		
			TF_ID		; TECHNOLOGY ID		
			RING_WIDTH	; RING WIDTH
			k			; counter
			j			; counter
			BOT			; variable for while
			IN_PORT		; INPUT PORT
			CONTROLLER_X
			CONTROLLER_Y
			temp
			temp_x
			temp_y
			temp_2_x
			temp_2_y
			SEL_BUS_W
			P_EN_BUS_W
			LVL_DOWN_X
			LVL_DOWN_Y
			SIGNALS_VDDL_Y
			SIGNALS_VDDL_X	
			X_SIZE
			Y_SIZE	
			TF_ID	
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("Creating Layout.\n")
	TF_ID=techGetTechFile(ddGetObj("tsmc18"))
	
	; STEP 1
	; GENERATE LAYOUT VIEW
	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view	

	; STEP 2
	; PLACE RRAM ARRAY
	DB_ANALOG_LAYOUT = dbOpenCellViewByType(DB_ANALOG~>libName DB_ANALOG~>cellName "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_ANALOG_LAYOUT  "RRAM_ANALOG" list(0 0) "R0")	
	
	sprintf(NET_NAME "Z_WR<%d>" B)	
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)	
	BOTTOM_Y=car(cdr(calculatePinPosition(DB_PIN)))-1.705
	RING_WIDTH = 6

	; STEP 3
	; PLACE CONTROLLER
	DB_CONTROLLER_LAYOUT = dbOpenCellViewByType(DB_CONTROLLER~>libName DB_CONTROLLER~>cellName "layout" "maskLayout" "r")
	CONTROLLER_Y = -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-8 ;-3.03-(Y-1)*2.28
	sprintf(FILE "./DIGITAL/reports/CONTROLLER_5V_%d_%d_%d/CONTROLLER_5V_%d_%d_%d_innovus_size.rep" X Y B X Y B)
	IN_PORT = infile(FILE)		
	gets( line IN_PORT)				
	sscanf(line "x = %f" CONTROLLER_X)
	gets( line IN_PORT)				
	sscanf(line "y = %f" temp)
	close(IN_PORT)	
	SEL_BUS_W=(Y+1)*0.56
	EN_BUS_W = 2*((X/B+2)*0.56+(X/B+1)*0.56)+3*0.56
	if( SEL_BUS_W > EN_BUS_W then
		CONTROLLER_X=-CONTROLLER_X-1.705-SEL_BUS_W
	else
		CONTROLLER_X=-CONTROLLER_X-1.705-EN_BUS_W
	)

	CONTROLLER_Y=CONTROLLER_Y+1.705
	dbCreateInst(CELLVIEW DB_CONTROLLER_LAYOUT  "CONTROLLER" list(CONTROLLER_X CONTROLLER_Y) "R0")


	; STEP 4 CONNECT CONTROLLER TO A_RRAM
	; CONNECT SEL
	j=Y-1
	k=1
	while( j>=0
		sprintf(NET_NAME "SEL[%d]" j)		
		temp_x = car(calculateBusPinPositionDigital(NET_NAME "SEL" DB_CONTROLLER_LAYOUT))-0.365
		;printf("temp_x %f\n" temp_x)
		temp_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "SEL" DB_CONTROLLER_LAYOUT)))
		;printf("temp_y %f\n" temp_y)
		sprintf(NET_NAME "SEL<%d>" j+1)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_2_x = car(calculatePinPosition(DB_PIN))
		;printf("temp_2y %f\n" temp_2_x)
		temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
		sprintf(NET_NAME "SEL<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y -1.705-k*0.56:temp_y+CONTROLLER_Y -1.705-k*0.56:temp_2_y 0:temp_2_y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)
		j=j-1
		k=k+1
	)
	
	; CONNECT P_EN
	for( j 0 X/B
		sprintf(NET_NAME "P_EN[%d]" j)	
		temp_x = car(calculateBusPinPositionDigital(NET_NAME "P_EN" DB_CONTROLLER_LAYOUT))-0.365
		;printf("temp_x %f\n" temp_x)
		temp_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "P_EN" DB_CONTROLLER_LAYOUT)))
		;printf("temp_y %f\n" temp_y)
		sprintf(NET_NAME "P_EN<%d>" j+1)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_2_x = car(calculatePinPosition(DB_PIN))
		temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
		sprintf(NET_NAME "P_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y temp_x+CONTROLLER_X+(j+3)*0.56:temp_y+CONTROLLER_Y temp_x+CONTROLLER_X+(j+3)*0.56:temp_2_y temp_2_x:temp_2_y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)
	)

	start = temp_x+CONTROLLER_X+(X/B+3)*0.56+0.56
	; CONNECT NOT_P_EN
	for( j 0 X/B
		sprintf(NET_NAME "P_NOT_EN[%d]" j)	
		temp_x = car(calculateBusPinPositionDigital(NET_NAME "P_NOT_EN" DB_CONTROLLER_LAYOUT))-0.365
		;printf("temp_x %f\n" temp_x)
		temp_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "P_NOT_EN" DB_CONTROLLER_LAYOUT)))
		;printf("temp_y %f\n" temp_y)
		sprintf(NET_NAME "P_NOT_EN<%d>" j+1)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_2_x = car(calculatePinPosition(DB_PIN))
		temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
		sprintf(NET_NAME "P_NOT_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y j*0.56+start:temp_y+CONTROLLER_Y j*0.56+start:temp_2_y temp_2_x:temp_2_y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)
	)

	start = X/B*0.56+start+0.56
	; CONNECT N_EN
	for( j 0 X/B-1
		sprintf(NET_NAME "N_EN[%d]" j)	
		temp_x = car(calculateBusPinPositionDigital(NET_NAME "N_EN" DB_CONTROLLER_LAYOUT))-0.365
		;printf("temp_x %f\n" temp_x)
		temp_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "N_EN" DB_CONTROLLER_LAYOUT)))
		;printf("temp_y %f\n" temp_y)
		sprintf(NET_NAME "N_EN<%d>" j+1)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_2_x = car(calculatePinPosition(DB_PIN))
		temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
		sprintf(NET_NAME "N_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y j*0.56+start:temp_y+CONTROLLER_Y j*0.56+start:temp_2_y temp_2_x:temp_2_y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)
	)

	start = (X/B-1)*0.56+start+0.56
	; CONNECT N_NOT_EN
	for( j 0 X/B-1
		sprintf(NET_NAME "N_NOT_EN[%d]" j)	
		temp_x = car(calculateBusPinPositionDigital(NET_NAME "N_NOT_EN" DB_CONTROLLER_LAYOUT))-0.365
		;printf("temp_x %f\n" temp_x)
		temp_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "N_NOT_EN" DB_CONTROLLER_LAYOUT)))
		;printf("temp_y %f\n" temp_y)
		sprintf(NET_NAME "N_NOT_EN<%d>" j+1)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_2_x = car(calculatePinPosition(DB_PIN))
		temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
		sprintf(NET_NAME "N_NOT_EN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y j*0.56+start:temp_y+CONTROLLER_Y j*0.56+start:temp_2_y temp_2_x:temp_2_y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)
	)

	start = (X/B-1)*0.56+start+0.56
	sprintf(NET_NAME "NOT_WRITE")	
	temp_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))-0.365
	temp_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))
	sprintf(NET_NAME "NOT_WRITE_H")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_2_x = car(calculatePinPosition(DB_PIN))
	temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
	sprintf(NET_NAME "NOT_WRITE_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y 0.56+start:temp_y+CONTROLLER_Y 0.56+start:temp_2_y temp_2_x:temp_2_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	start = start+0.56
	sprintf(NET_NAME "WRITE")	
	temp_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))-0.365
	temp_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))
	sprintf(NET_NAME "WRITE_H")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_2_x = car(calculatePinPosition(DB_PIN))
	temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
	sprintf(NET_NAME "WRITE_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y 0.56+start:temp_y+CONTROLLER_Y 0.56+start:temp_2_y temp_2_x:temp_2_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	; PLACE LVL_DOWN
	LVL_DOWN_X = CONTROLLER_X+(0.56+1.12*5)
	LVL_DOWN_Y = CONTROLLER_Y-1.705-16
	dbCreateInst(CELLVIEW DB_LEVEL_DOWN_LAYOUT  "LEVEL_DOWN" list( LVL_DOWN_X LVL_DOWN_Y ) "R0")
	
	sprintf(NET_NAME "DVLP")	
	temp_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))
	printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+0.365
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "DVLP_H_IN")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_2_x = car(calculatePinPosition(DB_PIN))
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "DVLP_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y temp_x+CONTROLLER_X:temp_2_y+LVL_DOWN_Y temp_2_x+LVL_DOWN_X:temp_2_y+LVL_DOWN_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x+LVL_DOWN_X temp_2_y+LVL_DOWN_Y) "R0" 
                                     	list( 
									list("cutRows" 1)             ;row
                                     	list("cutColumns" 2)               ;column                                             	
									)
	)

	sprintf(NET_NAME "PRE")	
	temp_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+0.365
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "PRE_H_IN")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_2_x = car(calculatePinPosition(DB_PIN))
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "PRE_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y temp_x+CONTROLLER_X:temp_2_y+LVL_DOWN_Y temp_2_x+LVL_DOWN_X:temp_2_y+LVL_DOWN_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x+LVL_DOWN_X temp_2_y+LVL_DOWN_Y) "R0" 
                                     	list( 
									list("cutRows" 1)             ;row
                                     	list("cutColumns" 2)               ;column                                             	
									)
	)

	sprintf(NET_NAME "READ")	
	temp_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+0.365
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "READ_VDDH_IN")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_2_x = car(calculatePinPosition(DB_PIN))
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "READ_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y temp_x+CONTROLLER_X:temp_2_y+LVL_DOWN_Y temp_2_x+LVL_DOWN_X:temp_2_y+LVL_DOWN_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x+LVL_DOWN_X temp_2_y+LVL_DOWN_Y) "R0" 
                                     	list( 
									list("cutRows" 1)             ;row
                                     	list("cutColumns" 2)               ;column                                             	
									)
	)

	sprintf(NET_NAME "EN_SA")	
	temp_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+0.365
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "SA_EN_H_IN")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_2_x = car(calculatePinPosition(DB_PIN))
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "SA_EN_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y temp_x+CONTROLLER_X:temp_2_y+LVL_DOWN_Y temp_2_x+LVL_DOWN_X:temp_2_y+LVL_DOWN_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x+LVL_DOWN_X temp_2_y+LVL_DOWN_Y) "R0" 
                                     	list( 
									list("cutRows" 1)             ;row
                                     	list("cutColumns" 2)               ;column                                             	
									)
	)

	sprintf(NET_NAME "WRITE_2")	
	temp_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+0.365
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "WRITE_VDDH_IN")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_2_x = car(calculatePinPosition(DB_PIN))
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "WRITE_2_H")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(temp_x+CONTROLLER_X:temp_y+CONTROLLER_Y temp_x+CONTROLLER_X:temp_2_y+LVL_DOWN_Y temp_2_x+LVL_DOWN_X:temp_2_y+LVL_DOWN_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x+LVL_DOWN_X temp_2_y+LVL_DOWN_Y) "R0" 
                                     	list( 
									list("cutRows" 1)             ;row
                                     	list("cutColumns" 2)               ;column                                             	
									)
	)


	; STEP 5
	; PLACE SIGNALS
	DB_SIGNALS_VDDL_LAYOUT = dbOpenCellViewByType(DB_SIGNALS_VDDL~>libName DB_SIGNALS_VDDL~>cellName "layout" "maskLayout" "r")
	SIGNALS_VDDL_Y = -7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-16.39-1-(B-1)*0.62-1-8+1.705 
	SIGNALS_VDDL_X = LVL_DOWN_X+32+1.705+1.705
	dbCreateInst(CELLVIEW DB_SIGNALS_VDDL_LAYOUT  "SIGNALS_VDDL" list(SIGNALS_VDDL_X SIGNALS_VDDL_Y) "R0")

	sprintf(NET_NAME "WRITE_VDDH_OUT")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)	
	sprintf(NET_NAME "WRITE_VDDH")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))+0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "WRITE_BUF")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+LVL_DOWN_X:temp_y+LVL_DOWN_Y temp_x+LVL_DOWN_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	
	
	
	sprintf(NET_NAME "dummy_en")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))+0.365
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "VDDL")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:SIGNALS_VDDL_Y-RING_WIDTH ) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x+SIGNALS_VDDL_X SIGNALS_VDDL_Y-RING_WIDTH) "R0" 
                                     	list( 
									list("cutRows" 1)             ;row
                                     	list("cutColumns" 1)               ;column                                             	
									)
	)
	
	
	sprintf(NET_NAME "PRE_H_OUT")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)	
	sprintf(NET_NAME "PRE_H")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))+0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "PRE_BUF")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+LVL_DOWN_X:temp_y+LVL_DOWN_Y temp_x+LVL_DOWN_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "READ_VDDH_OUT")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)	
	sprintf(NET_NAME "READ_VDDH")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))+0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "READ_BUF")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+LVL_DOWN_X:temp_y+LVL_DOWN_Y temp_x+LVL_DOWN_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "DVLP_H_OUT")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)	
	sprintf(NET_NAME "DVLP_H")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))+0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "DVLP_BUF")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+LVL_DOWN_X:temp_y+LVL_DOWN_Y temp_x+LVL_DOWN_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "SA_EN_H_OUT")
	DB_PIN = setof(TERM DB_LEVEL_DOWN_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)	
	sprintf(NET_NAME "SA_EN_H")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))+0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "SA_EN_BUF")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_x+LVL_DOWN_X:temp_y+LVL_DOWN_Y temp_x+LVL_DOWN_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	

		
	sprintf(NET_NAME "WRITE_VDDL")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "WRITE_L")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "WRITE_L")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*2:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*2:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "NOT_WRITE_VDDL")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "NOT_WRITE_L")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "NOT_WRITE_L")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)
	
	sprintf(NET_NAME "NOT_READ_VDDL_1")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "NOT_READ")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "NOT_READ_L_1")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*5:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*5:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "READ_VDDL_1")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "READ")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "READ_L_1")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "DVLP_L")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "DVLP")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "DVLP_L")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*2:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*2:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "PRE_L")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "PRE")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "PRE_L")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)


	sprintf(NET_NAME "SA_EN_L")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "SA_EN")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "SA_EN_L")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*4:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*4:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "NOT_READ_VDDL_2")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "NOT_READ_2")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "NOT_READ_L_2")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*5:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*5:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	sprintf(NET_NAME "READ_VDDL_2")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))-0.365
	;printf("temp2_x = %f\n" temp_2_x)
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))
	;printf("temp2_y = %f\n" temp_2_y)
	sprintf(NET_NAME "READ_2")
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	temp_x = car(calculatePinPosition(DB_PIN))
	;printf("temp_x = %f\n" temp_x)
	temp_y = car(cdr(calculatePinPosition(DB_PIN)))
	;printf("temp_y = %f\n" temp_y)
	sprintf(NET_NAME "READ_L_2")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X+0.56*3:temp_y temp_x:temp_y) 0.28)
	;printf("temp_2y %f\n" temp_2_y)
	dbAddFigToNet(PATH_ID NET_ID)

	for( j 1 B
		sprintf(NET_NAME "Z_SA[%d]" j-1)	
		temp_2_x = car(calculateBusPinPositionDigital(NET_NAME "Z_SA" DB_SIGNALS_VDDL_LAYOUT))
		;printf("temp2_x = %f\n" temp_2_x)
		temp_2_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "Z_SA" DB_SIGNALS_VDDL_LAYOUT)))+0.365
		;printf("temp2_y = %f\n" temp_2_y)
		sprintf(NET_NAME "Z_SA<%d>" j)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_x = car(calculatePinPosition(DB_PIN))
		;printf("temp_x = %f\n" temp_x)
		temp_y = car(cdr(calculatePinPosition(DB_PIN)))
		;printf("temp_y = %f\n" temp_y)
		sprintf(NET_NAME "Z_SA<%d>" j-1)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:temp_y temp_x:temp_y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)
	)

	for( j 1 B
		sprintf(NET_NAME "Z_BUS[%d]" j-1)	
		temp_2_x = car(calculateBusPinPositionDigital(NET_NAME "Z_BUS" DB_SIGNALS_VDDL_LAYOUT))
		;printf("temp2_x = %f\n" temp_2_x)
		temp_2_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "Z_BUS" DB_SIGNALS_VDDL_LAYOUT)))+0.365
		;printf("temp2_y = %f\n" temp_2_y)
		sprintf(NET_NAME "Z_WR<%d>" j)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_x = car(calculatePinPosition(DB_PIN))
		;printf("temp_x = %f\n" temp_x)
		temp_y = car(cdr(calculatePinPosition(DB_PIN)))
		;printf("temp_y = %f\n" temp_y)
		sprintf(NET_NAME "Z_BUS<%d>" j-1)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x+SIGNALS_VDDL_X:temp_2_y+SIGNALS_VDDL_Y temp_2_x+SIGNALS_VDDL_X:temp_y temp_x:temp_y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)
	)
	

	; INPUT PINS LEFT
	; CONTROLLER
	; EN
	sprintf(NET_NAME "EN")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	dbAddFigToNet(RECT_ID NET_ID)

	; reset
	sprintf(NET_NAME "reset")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	dbAddFigToNet(RECT_ID NET_ID)

	; rw
	sprintf(NET_NAME "RW")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	dbAddFigToNet(RECT_ID NET_ID)

	; clock
	sprintf(NET_NAME "clk")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
	PIN_ID~>term~>direction = "input"
	leAttachFig(LABEL_ID PIN_ID~>fig)	
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
	dbAddFigToNet(RECT_ID NET_ID)
	
	X_SIZE=int(log(X/B)/log(2))
	for( j 0 X_SIZE-1
		sprintf(NET_NAME "X_ADDRESS_IN[%d]" j)	
		temp_2_x = car(calculateBusPinPositionDigital(NET_NAME "X_ADDRESS_IN" DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
		temp_2_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "X_ADDRESS_IN" DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
		sprintf(NET_NAME "X_ADDRESS_IN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
		dbAddFigToNet(RECT_ID NET_ID)
	)

	Y_SIZE=int(log(Y)/log(2))
	for( j 0 Y_SIZE-1
		sprintf(NET_NAME "Y_ADDRESS_IN[%d]" j)	
		temp_2_x = car(calculateBusPinPositionDigital(NET_NAME "Y_ADDRESS_IN" DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
		temp_2_y = car(cdr(calculateBusPinPositionDigital(NET_NAME "Y_ADDRESS_IN" DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "pin") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
		sprintf(NET_NAME "Y_ADDRESS_IN<%d>" j)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL2" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
		RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.365:temp_2_y-0.14 temp_2_x+0.365:temp_2_y+0.14))
		dbAddFigToNet(RECT_ID NET_ID)
	)


	; VDDH
	sprintf(NET_NAME "VDD")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	sprintf(NET_NAME "VDDH")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	; VSS
	sprintf(NET_NAME "VSS")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	sprintf(NET_NAME "VSS")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") temp_2_x:temp_2_y NET_NAME "upperCenter" "R0" "roman" 0.1)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	


	; PIN VDDW
	NET_ID=dbMakeNet(CELLVIEW "VDDW")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(-0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-0.115 
															0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62+0.115))
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 0:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62 "VDDW" "upperCenter" "R0" "roman" 1.25)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	

	; GENERATE PIN VDDL 1.8
	; PIN VDDL
	NET_ID=dbMakeNet(CELLVIEW "VDDL")
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(B*35-B*15-0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-7-0.115 
															B*35-B*15+0.115:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-7+0.115))
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	dbAddFigToNet(RECT_ID NET_ID)
	PIN_ID=dbCreatePin(NET_ID RECT_ID)
	LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") B*35-B*15:-7.43-2*(X/B+1)*0.62-0.62-B*0.62-16-1-2*X/B*0.62-0.62-16-1-B*0.62-0.62-16-1-2*B*0.62+0.62-1-16-1-2*B*0.62-0.62-1-7 "VDDL" "upperCenter" "R0" "roman" 1.25)		
	PIN_ID~>term~>direction = "inputOutput"
	leAttachFig(LABEL_ID PIN_ID~>fig)	


	; MR PINS
	for(j 1 X*Y
		sprintf(NET_NAME "MR<%d>" j)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_x = car(calculatePinPosition(DB_PIN))
		;printf("temp_x = %f\n" temp_x)
		temp_y = car(cdr(calculatePinPosition(DB_PIN)))
		;printf("temp_y = %f\n" temp_y)
		sprintf(NET_NAME "MR<%d>" j-1)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "pin") list(temp_x-0.115:temp_y-0.115 temp_x+0.115:temp_y+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") temp_x:temp_y NET_NAME "upperCenter" "R0" "roman" 0.02)		
		PIN_ID~>term~>direction = "inputOutput"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
	)

	; MR PINS
	for(j 1 X
		sprintf(NET_NAME "P<%d>" j)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_x = car(calculatePinPosition(DB_PIN))
		;printf("temp_x = %f\n" temp_x)
		temp_y = car(cdr(calculatePinPosition(DB_PIN)))
		;printf("temp_y = %f\n" temp_y)
		sprintf(NET_NAME "P<%d>" j-1)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "pin") list(temp_x-0.115:temp_y-0.115 temp_x+0.115:temp_y+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") temp_x:temp_y NET_NAME "upperCenter" "R0" "roman" 0.02)		
		PIN_ID~>term~>direction = "inputOutput"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
	)

	
	sprintf(NET_NAME "Z_WR<%d>" B)	
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)	
	BOTTOM_Y=car(cdr(calculatePinPosition(DB_PIN)))-1.705
	;printf("Y=%f\n" BOTTOM_Y)
	;Z_BUS PINS
	for(j 1 B
		sprintf(NET_NAME "Z_WR<%d>" j)
		DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
		temp_x = car(calculatePinPosition(DB_PIN))
		;printf("temp_x = %f\n" temp_x)
		temp_y = car(cdr(calculatePinPosition(DB_PIN)))
		;printf("temp_y = %f\n" temp_y)
		VIA_ID=techFindViaDefByName(TF_ID "M3_M2")
		dbCreateVia( CELLVIEW VIA_ID list(temp_x-1.12*5-1.12*j temp_y) "R0" 
                                         	list( 
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 2)               ;column                                             	
										)
		)
		sprintf(NET_NAME "Z_BUS<%d>" j-1)
		NET_ID =dbMakeNet(CELLVIEW NET_NAME)
		PATH_ID= dbCreatePath(CELLVIEW list("METAL3" "drawing") list(temp_x-1.12*5-1.12*j:temp_y temp_x-1.12*5-1.12*j:BOTTOM_Y) 0.28)
		;printf("temp_2y %f\n" temp_2_y)
		dbAddFigToNet(PATH_ID NET_ID)		
		RECT_ID = dbCreateRect(CELLVIEW list("METAL3" "pin") list(temp_x-1.12*5-1.12*j-0.115:BOTTOM_Y-0.115 temp_x-1.12*5-1.12*j+0.115:BOTTOM_Y+0.115))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL3" "pin") temp_x-1.12*5-1.12*j:BOTTOM_Y NET_NAME "upperCenter" "R0" "roman" 0.02)		
		PIN_ID~>term~>direction = "inputOutput"
		leAttachFig(LABEL_ID PIN_ID~>fig)	
	)

	
	; VSS GUARDRINGS
	TOP_Y = (Y-1)*2.28+3.03
	CORNER_1_Y =  car(cdr(calculatePinPositionDigital("SA_EN_H" DB_SIGNALS_VDDL_LAYOUT)))-1.705+SIGNALS_VDDL_Y
	sprintf(NET_NAME "Z_BUS[%d]" B-1)	
	CORNER_2_X = car(calculateBusPinPositionDigital(NET_NAME "Z_BUS" DB_SIGNALS_VDDL_LAYOUT))-1.705+SIGNALS_VDDL_X	
	sprintf(NET_NAME "Z_WR<%d>" B)
	DB_PIN = setof(TERM DB_ANALOG_LAYOUT~>terminals TERM~>name==NET_NAME)		
	CORNER_3_X = car(calculatePinPosition(DB_PIN))+0.21-1.82
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(
							-1.705+0.21:TOP_Y
							CONTROLLER_X-1.705:TOP_Y
							CONTROLLER_X-1.705:LVL_DOWN_Y
							CONTROLLER_X+0.7+6.16:LVL_DOWN_Y							
							)
							?netName "VSS")
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(
							CONTROLLER_X+29.035-1.915:LVL_DOWN_Y
							CONTROLLER_X+37.485-2*1.705:LVL_DOWN_Y
							CONTROLLER_X+37.485-2*1.705:CORNER_1_Y
							SIGNALS_VDDL_X-1.705:CORNER_1_Y
							SIGNALS_VDDL_X-1.705:SIGNALS_VDDL_Y-1.705
							CORNER_2_X:SIGNALS_VDDL_Y-1.705
							CORNER_2_X:BOTTOM_Y
							CORNER_3_X:BOTTOM_Y
							)
							?netName "VSS")

	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(
							LVL_DOWN_X+32-0.7:LVL_DOWN_Y+16
							-1.705*2:LVL_DOWN_Y+16
							)
							?netName "VSS")

	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(
							SIGNALS_VDDL_X-1.705:CORNER_1_Y-0.21
							SIGNALS_VDDL_X-1.705:LVL_DOWN_Y+16-1.705
							)
							?netName "VSS")

	sprintf(NET_NAME "VSS")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("DIFF" "drawing") list(-1.705*2:LVL_DOWN_Y+16
															-1.705:LVL_DOWN_Y+16) 
	0.42)
	PATH_ID= dbCreatePath(CELLVIEW list("PIMP" "drawing") list(-1.705*2:LVL_DOWN_Y+16
															-1.705:LVL_DOWN_Y+16) 
	0.78)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(-1.705*2:LVL_DOWN_Y+16
															-1.705:LVL_DOWN_Y+16) 
	0.34)
	dbAddFigToNet(PATH_ID NET_ID)	

	
	sprintf(NET_NAME "VSS")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("DIFF" "drawing") list(CONTROLLER_X-1.705:LVL_DOWN_Y+16
															CONTROLLER_X+8.355:LVL_DOWN_Y+16) 
	0.42)
	PATH_ID= dbCreatePath(CELLVIEW list("PIMP" "drawing") list(CONTROLLER_X-1.705:LVL_DOWN_Y+16
															CONTROLLER_X+8.355:LVL_DOWN_Y+16) 
	0.78)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(CONTROLLER_X-1.705:LVL_DOWN_Y+16
															CONTROLLER_X+8.355:LVL_DOWN_Y+16) 
	0.34)
	dbAddFigToNet(PATH_ID NET_ID)	

	sprintf(NET_NAME "VSS")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("DIFF" "drawing") list(SIGNALS_VDDL_X-1.705:LVL_DOWN_Y+16-1.705
															SIGNALS_VDDL_X-1.705:LVL_DOWN_Y+16) 
	0.42)
	PATH_ID= dbCreatePath(CELLVIEW list("PIMP" "drawing") list(SIGNALS_VDDL_X-1.705:LVL_DOWN_Y+16-1.705
															SIGNALS_VDDL_X-1.705:LVL_DOWN_Y+16) 
	0.78)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(SIGNALS_VDDL_X-1.705:LVL_DOWN_Y+16-1.705
															SIGNALS_VDDL_X-1.705:LVL_DOWN_Y+16) 
	0.34)
	dbAddFigToNet(PATH_ID NET_ID)	

	; POWER RING
	sprintf(NET_NAME "VDDL")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(
															0:TOP_Y+RING_WIDTH
															CONTROLLER_X-1.705-RING_WIDTH:TOP_Y+RING_WIDTH
															CONTROLLER_X-1.705-RING_WIDTH:LVL_DOWN_Y-RING_WIDTH
															CONTROLLER_X+37.485-2*1.705-RING_WIDTH:LVL_DOWN_Y-RING_WIDTH
															CONTROLLER_X+37.485-2*1.705-RING_WIDTH:CORNER_1_Y-RING_WIDTH
															SIGNALS_VDDL_X-1.705-RING_WIDTH:CORNER_1_Y-RING_WIDTH
															SIGNALS_VDDL_X-1.705-RING_WIDTH:SIGNALS_VDDL_Y-1.705-RING_WIDTH
															CORNER_2_X-RING_WIDTH:SIGNALS_VDDL_Y-1.705-RING_WIDTH
															CORNER_2_X-RING_WIDTH:BOTTOM_Y-RING_WIDTH
															B*35+1.705+RING_WIDTH:BOTTOM_Y-RING_WIDTH
															B*35+1.705+RING_WIDTH:BOTTOM_Y
															)															
	RING_WIDTH)
	dbAddFigToNet(PATH_ID NET_ID)	
	; VDDH
	RING_WIDTH = 6
	sprintf(NET_NAME "VDDH")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(
															0:TOP_Y+RING_WIDTH*5/2
															CONTROLLER_X-1.705-RING_WIDTH*5/2:TOP_Y+RING_WIDTH*5/2
															CONTROLLER_X-1.705-RING_WIDTH*5/2:LVL_DOWN_Y-RING_WIDTH*5/2
															CONTROLLER_X+37.485-2*1.705-RING_WIDTH*5/2:LVL_DOWN_Y-RING_WIDTH*5/2
															CONTROLLER_X+37.485-2*1.705-RING_WIDTH*5/2:CORNER_1_Y-RING_WIDTH*5/2
															SIGNALS_VDDL_X-1.705-RING_WIDTH*5/2:CORNER_1_Y-RING_WIDTH*5/2
															SIGNALS_VDDL_X-1.705-RING_WIDTH*5/2:SIGNALS_VDDL_Y-1.705-RING_WIDTH*5/2
															CORNER_2_X-RING_WIDTH*5/2:SIGNALS_VDDL_Y-1.705-RING_WIDTH*5/2
															CORNER_2_X-RING_WIDTH*5/2:BOTTOM_Y-RING_WIDTH*5/2
															B*35+1.705+RING_WIDTH*5/2:BOTTOM_Y-RING_WIDTH*5/2
															B*35+1.705+RING_WIDTH*5/2:BOTTOM_Y
															)															
	RING_WIDTH)
	dbAddFigToNet(PATH_ID NET_ID)	

	; CONNECT CONTROLLER TO POWER
	; VDDH
	sprintf(NET_NAME "VDD")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	sprintf(NET_NAME "VDDH")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	dbAddFigToNet(RECT_ID NET_ID)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	dbAddFigToNet(RECT_ID NET_ID)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x:temp_2_y temp_2_x:TOP_Y+RING_WIDTH*5/2) 1.8)
	dbAddFigToNet(PATH_ID NET_ID)

	VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x temp_2_y) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 2))               ;column                                             	
			
	)
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x TOP_Y+RING_WIDTH*5/2) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 2))               ;column                                             	
			
	)

	; VSS CONTROLLER
	sprintf(NET_NAME "VSS")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT))+CONTROLLER_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_CONTROLLER_LAYOUT)))+CONTROLLER_Y
	sprintf(NET_NAME "VSS")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	dbAddFigToNet(RECT_ID NET_ID)	
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(temp_2_x:temp_2_y temp_2_x:TOP_Y) 1.8)
	dbAddFigToNet(PATH_ID NET_ID)

	; VDDL LVL DOWN
	dbCreateVia( CELLVIEW VIA_ID list(LVL_DOWN_X+1.5 LVL_DOWN_Y+8) "R0" 
                                         	list( 
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 3))               ;column                                             	
			
	)
	dbCreateVia( CELLVIEW VIA_ID list(CONTROLLER_X-1.705-RING_WIDTH LVL_DOWN_Y+8) "R0" 
                                         	list( 
										list("cutRows" 1)             ;row
                                         	list("cutColumns" 3))               ;column                                             	
			
	)
	sprintf(NET_NAME "VDDL")	
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(LVL_DOWN_X+1.5:LVL_DOWN_Y+8 CONTROLLER_X-1.705-RING_WIDTH:LVL_DOWN_Y+8) 0.38)
	dbAddFigToNet(PATH_ID NET_ID)

	; CONNECT CONTROLLER TO POWER
	; VDDH
	sprintf(NET_NAME "VDD")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))+SIGNALS_VDDL_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))+SIGNALS_VDDL_Y
	sprintf(NET_NAME "VDDL")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	dbAddFigToNet(RECT_ID NET_ID)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL2" "drawing") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	dbAddFigToNet(RECT_ID NET_ID)
	PATH_ID= dbCreatePath(CELLVIEW list("METAL2" "drawing") list(temp_2_x:temp_2_y temp_2_x:SIGNALS_VDDL_Y-1.705-RING_WIDTH) 1.8)
	dbAddFigToNet(PATH_ID NET_ID)

	VIA_ID=techFindViaDefByName(TF_ID "M2_M1")
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x temp_2_y) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 2))               ;column                                             	
			
	)
	dbCreateVia( CELLVIEW VIA_ID list(temp_2_x SIGNALS_VDDL_Y-1.705-RING_WIDTH) "R0" 
                                         	list( 
										list("cutRows" 2)             ;row
                                         	list("cutColumns" 2))               ;column                                             	
			
	)

	; VSS SIGNALS_VDDL
	sprintf(NET_NAME "VSS")	
	temp_2_x = car(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT))+SIGNALS_VDDL_X	
	temp_2_y = car(cdr(calculatePinPositionDigital(NET_NAME DB_SIGNALS_VDDL_LAYOUT)))+SIGNALS_VDDL_Y
	sprintf(NET_NAME "VSS")
	NET_ID =dbMakeNet(CELLVIEW NET_NAME)
	RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(temp_2_x-0.9:temp_2_y-0.9 temp_2_x+0.9:temp_2_y+0.9))
	dbAddFigToNet(RECT_ID NET_ID)	
	PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(temp_2_x:temp_2_y temp_2_x:SIGNALS_VDDL_Y-1.705) 1.8)
	dbAddFigToNet(PATH_ID NET_ID)
	

	dbSave(CELLVIEW)		; Save
	return(CELLVIEW)	
	)	;prog
)	;PROCEDURE
