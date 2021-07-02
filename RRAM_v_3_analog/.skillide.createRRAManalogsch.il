;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			22/06/2021
; Description:	This file contains the main function SKILL code to create the RRAM Analog Part Schematic
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAManalogsch(					; LIST OF ARGUMENTS
							X 					; X SIZE OF ARRAY (COLS)
							Y					; Y SIZE OF ARRAY (ROWS)
							B					; B (BITS) SIZE OF A WORD
							LIBRARY				; LIBRARY TO PLACE THE NEW DESIGN
							NAME					; NAME OF THE CELLVIEW
							DB_RRAM_SCH			; DB OF RRAM SCH CELLVIEW
							DB_PMUX_SCH	
							DB_NMUX_SCH		
							DB_REF_SCH	
							DB_SA
							DB_WR
									
						)
	prog( 	(			; LIST OF LOCAL VARIABLES
				CELLVIEW		; DB OF CELLVIEW
				INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
				MASTER_CV	; DB OF CELLVIEW
				DB_PIN
				POINT
				TERM
				;INST_ID		; TEMPORARY VARIABLE to HOLD THE DB OF INSTANCE
				NET_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF THE NET
				NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
				PIN_CV_ID	; TEMPORARY VARIABLE TO HOLD THE DB OF THE PIN
				;PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF NEW PIN
				PIN_NAME		; TEMPORARY VARIABLE TO HOLD THE NAME OF A PIN
			)			; END OF LIST OF LOCAL VARIABLES
	
	printf("+++ Creating Schematic for Analog RRAM +++\n")


	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	

	;----------------------------------------------------------------------------------------------------------------
	; Create Instance RRAM ARRAY	
	MASTER_CV = dbOpenCellViewByType(DB_RRAM_SCH~>libName DB_RRAM_SCH~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "RRAM" list(0 0) "R0")
	; Create Nets and Pins
	; VSS
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name=="VSS")
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(POINT car(POINT):(car(cdr(POINT))+2)) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):(car(cdr(POINT))+2) "VSS" "upperCenter" "R0" "fixed" 0.05 nil )
	; VSS PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VSS" "inputOutput" nil car(POINT):(car(cdr(POINT))+2) "R0" nil nil "ground")		; VSS
	; Create P net. P<1:X>
	sprintf(NET_NAME "P<1:%d>" X)	; Columns share P
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(POINT car(POINT):(car(cdr(POINT))+1.75)) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):(car(cdr(POINT))+1.75) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; P PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "P<1:%d>" X)	; MR row representation
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT):(car(cdr(POINT))+1.75) "R0" )	
	; Create N net. N<1:X>
	sprintf(NET_NAME "N<1:%d>" X)	; Columns share N
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(POINT car(POINT):(car(cdr(POINT))+1.5)) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):(car(cdr(POINT))+1.5) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create MR<1:XY>
	sprintf(NET_NAME "MR<1:%d>" X*Y)	; MR row representation
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(POINT car(POINT):(car(cdr(POINT))+1.25)) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):(car(cdr(POINT))+1.25) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; MR PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "MR<1:%d>" X*Y)	; MR row representation
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT):(car(cdr(POINT))+1.25) "R0" )	
	; Create SEL net. SEL<1:Y>
	sprintf(NET_NAME "SEL<1:%d>" Y)	; Rows share SEL
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list((car(POINT)-2):car(cdr(POINT)) POINT) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) (car(POINT)-2):car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; SEL PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "SEL<1:%d>" Y)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil (car(POINT)-2):car(cdr(POINT)) "R0" )	
	;------------------------------------------------------------------------------------------------------------------------------

	;------------------------------------------------------------------------------------------------------------------------------
	; Create Instance REF ARRAY	
	MASTER_CV =	dbOpenCellViewByType(DB_REF_SCH~>libName DB_REF_SCH~>cellName "symbol" "" "r")	
	dbCreateInst(CELLVIEW MASTER_CV "REF" list(5 0) "R0")
	; Create SEL net. SEL<1:Y> FOR REF
	sprintf(NET_NAME "SEL<1:%d>" Y)	; Rows share SEL
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list((car(POINT)-2+5):car(cdr(POINT)) (car(POINT)+5):car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) (car(POINT)-2+5):car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create P net. P<X+1:X+B>
	sprintf(NET_NAME "P<1:%d>" B)	; Columns share P
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P<%d:%d>" X+1 X+B)	; Columns share P
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT)) car(POINT)+5:(car(cdr(POINT))+1.75)) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))+1.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create N net. N<X+1:X+B> to VSS
	sprintf(NET_NAME "N<1:%d>" B)	; Columns share P
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")	; Columns share P
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT)) car(POINT)+5:(car(cdr(POINT))+1.5)) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))+1.5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	;--------------------------------------------------------------------------------------------------------------------------------
	
	;--------------------------------------------------------------------------------------------------------------------------------
	; Create Instance PMUX ARRAY	
	MASTER_CV = dbOpenCellViewByType(DB_PMUX_SCH~>libName DB_PMUX_SCH~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV "PMUX" list(0 -5) "R0")
	; Create P_EN<1:X/B+1>
	sprintf(NET_NAME "EN<1:%d>" X/B+1)	; Columns share P
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P_EN<1:%d>" X/B+1)	; Columns share P
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-5 car(POINT)-2:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-2:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN P_EN<1:X/B+1>
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "P_EN<1:%d>" X/B+1)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-2:car(cdr(POINT))-5 "R0" )	
	; Create P_NOT_EN<1:X/B+1>
	sprintf(NET_NAME "NOT_EN<1:%d>" X/B+1)	; Columns share P
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P_NOT_EN<1:%d>" X/B+1)	; Columns share P
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-5 car(POINT)-2:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-2:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN P_NOT_EN<1:X/B+1>
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "P_NOT_EN<1:%d>" X/B+1)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-2:car(cdr(POINT))-5 "R0" )
	; VSS
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name=="VSS")
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-5 car(POINT):car(cdr(POINT))-5+2) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-5+2 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )	
	; VDD
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name=="VDD")
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-5 car(POINT):car(cdr(POINT))-5+1.75) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-5+1.75 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )
	; Create P_OUT<1:B+B>
	sprintf(NET_NAME "OUT<1:%d>" 2*B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P_OUT<1:%d>" 2*B)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-5 car(POINT):car(cdr(POINT))-5+1.5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-5+1.5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
	; Create P<1:X+B>
	sprintf(NET_NAME "BL<1:%d>" X+B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P<1:%d>" X+B)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-5 car(POINT):car(cdr(POINT))-5+1.25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-5+1.25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
	;-------------------------------------------------------------------------------------------------------------------------

	;-------------------------------------------------------------------------------------------------------------------------
	; Create Instance NMUX ARRAY		
	MASTER_CV =	dbOpenCellViewByType(DB_NMUX_SCH~>libName DB_NMUX_SCH~>cellName "symbol" "" "r")
	dbCreateInst(CELLVIEW  MASTER_CV "NMUX" list(0 -10) "R0")	
	; Create N_EN<1:X/B+1>
	sprintf(NET_NAME "EN<1:%d>" X/B)	; Columns share P
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "N_EN<1:%d>" X/B)	; Columns share P
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-10 car(POINT)-2:car(cdr(POINT))-10) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-2:car(cdr(POINT))-10 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN N_EN<1:X/B>
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "N_EN<1:%d>" X/B)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-2:car(cdr(POINT))-10 "R0" )	
	; Create N_NOT_EN<1:X/B+1>
	sprintf(NET_NAME "NOT_EN<1:%d>" X/B)	; Columns share P
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "N_NOT_EN<1:%d>" X/B)	; Columns share P
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-10 car(POINT)-2:car(cdr(POINT))-10) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-2:car(cdr(POINT))-10 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN N_NOT_EN<1:X/B+1>
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "N_NOT_EN<1:%d>" X/B)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-2:car(cdr(POINT))-10 "R0" )
	; VSS
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name=="VSS")
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-10 car(POINT):car(cdr(POINT))-10+2) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-10+2 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )	
	; VDD
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name=="VDD")
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-10 car(POINT):car(cdr(POINT))-10+1.75) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-10+1.75 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN VDD
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VDD" "inputOutput" nil car(POINT):car(cdr(POINT))-10+1.75 "R0" nil nil "power")
	; Create N_OUT<1:B>
	sprintf(NET_NAME "OUT<1:%d>" B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "N_OUT<1:%d>" B)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-10 car(POINT):car(cdr(POINT))-10+1.5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-10+1.5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	
	; Create N<1:X>
	sprintf(NET_NAME "BL<1:%d>" X)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "N<1:%d>" X)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-10 car(POINT):car(cdr(POINT))-10+1.25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-10+1.25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	;----------------------------------------------------------------------------------------------------------

	;----------------------------------------------------------------------------------------------------------
	; Create Instance WR ARRAY
	MASTER_CV = dbOpenCellViewByType(DB_WR~>libName DB_WR~>cellName "symbol" "" "r")
	sprintf(INST_NAME "WR<1:%d>" B) 	
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(0 -15) "R0")
	; Create WR_IN<1:B>
	sprintf(NET_NAME "IN")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WR_IN<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-15 car(POINT)-2:car(cdr(POINT))-15) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-2:car(cdr(POINT))-15 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN WR_IN<1:B>
	;PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	;sprintf(PIN_NAME "WR_IN<1:%d>" B)	
	;schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT)-2:car(cdr(POINT))-15 "R0" )
	; Create VDDL
	sprintf(NET_NAME "VDDL")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDL")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-15 car(POINT):car(cdr(POINT))-15+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-15+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN VDDL
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	schCreatePin( CELLVIEW PIN_CV_ID "VDDL" "inputOutput" nil car(POINT):car(cdr(POINT))-15+1 "R0" nil nil "power")
	; Create VDD
	sprintf(NET_NAME "VDDH")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDD")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-15 car(POINT):car(cdr(POINT))-15+0.75) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-15+0.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VSS
	sprintf(NET_NAME "VSS")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-15 car(POINT):car(cdr(POINT))-15-0.75) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-15-0.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create WR_P<1:B>
	sprintf(NET_NAME "P")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WR_P<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-15 car(POINT)+1:car(cdr(POINT))-15) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+1:car(cdr(POINT))-15 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create WR_N<1:B>
	sprintf(NET_NAME "N")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WR_N<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-15 car(POINT)+1:car(cdr(POINT))-15) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+1:car(cdr(POINT))-15 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	;-------------------------------------------------------------------------------------------------------------------------------

	;-------------------------------------------------------------------------------------------------------------------------------
	; Create Instance WR SW P ARRAY
	MASTER_CV = dbOpenCellViewByType("THESIS" "TG5" "symbol" "" "r")
	sprintf(INST_NAME "WR_P_SW<1:%d>" B) 	
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(5 -12) "R0")
	; Create WR_P<1:B>
	sprintf(NET_NAME "IN")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WR_P<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-12 car(POINT)+5-1:car(cdr(POINT))-12) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5-1:car(cdr(POINT))-12 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create P_OUT<1:B>
	sprintf(NET_NAME "OUT")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P_OUT<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-12 car(POINT)+5+1:car(cdr(POINT))-12) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5+1:car(cdr(POINT))-12 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VDD
	sprintf(NET_NAME "VDD")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDD" )	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-12 car(POINT)+5:car(cdr(POINT))-12+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-12+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VSS
	sprintf(NET_NAME "VSS")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS" )	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-12 car(POINT)+5:car(cdr(POINT))-12-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-12-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create WRITE
	sprintf(NET_NAME "S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WRITE")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-12 car(POINT)+5:car(cdr(POINT))-13) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-13 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN WRITE
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "WRITE")
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)+5:car(cdr(POINT))-13 "R0" )	
	; Create NOT_WRITE
	sprintf(NET_NAME "NOT_S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "NOT_WRITE")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-12 car(POINT)+5:car(cdr(POINT))-11) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-11 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN WRITE
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "NOT_WRITE")
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)+5:car(cdr(POINT))-11 "R0" )	
	;------------------------------------------------------------------------------------------------------------------------------
	
	;------------------------------------------------------------------------------------------------------------------------------
	; Create Instance WR SW N ARRAY
	MASTER_CV = dbOpenCellViewByType("THESIS" "TG5" "symbol" "" "r")
	sprintf(INST_NAME "WR_N_SW<1:%d>" B) 	
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(10 -12) "R0")
	; Create WR_N<1:B>
	sprintf(NET_NAME "IN")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WR_N<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-12 car(POINT)+10-1:car(cdr(POINT))-12) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10-1:car(cdr(POINT))-12 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create N_OUT<1:B>
	sprintf(NET_NAME "OUT")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "N_OUT<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-12 car(POINT)+10+1:car(cdr(POINT))-12) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10+1:car(cdr(POINT))-12 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VDD
	sprintf(NET_NAME "VDD")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDD" )	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-12 car(POINT)+10:car(cdr(POINT))-12+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-12+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VSS
	sprintf(NET_NAME "VSS")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS" )	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-12 car(POINT)+10:car(cdr(POINT))-12-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-12-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create WRITE
	sprintf(NET_NAME "S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WRITE")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-12 car(POINT)+10:car(cdr(POINT))-13) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-13 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create NOT_WRITE
	sprintf(NET_NAME "NOT_S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "NOT_WRITE")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-12 car(POINT)+10:car(cdr(POINT))-11) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-11 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	;--------------------------------------------------------------------------------------------------------------------------

	;--------------------------------------------------------------------------------------------------------------------------
	; Create Instance SA ARRAY	
	if( DB_SA~>cellName == "SENSE_AMPLIFIER_LATCH_TYPE"
		then
		MASTER_CV = dbOpenCellViewByType(DB_SA~>libName DB_SA~>cellName "symbol" "" "r")
		sprintf(INST_NAME "SA<1:%d>" B) 	
		dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(0 -20) "R0")		
		; Create VDDL
		sprintf(NET_NAME "VDD")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "VDDL" )	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT):car(cdr(POINT))-20+1) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-20+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
		; Create VSS
		sprintf(NET_NAME "VSS")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "VSS" )	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT):car(cdr(POINT))-20-1) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-20-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
		; Create DVLP
		sprintf(NET_NAME "DVLP")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "DVLP" )	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT)-1:car(cdr(POINT))-20) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT))-20 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
		; PIN DVLP
		PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
		sprintf(PIN_NAME "DVLP")
		schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1:car(cdr(POINT))-20 "R0" )
		; Create SA_EN
		sprintf(NET_NAME "EN")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "SA_EN" )	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT)-1.25:car(cdr(POINT))-20) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1.25:car(cdr(POINT))-20 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
		; PIN SA_EN
		PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
		sprintf(PIN_NAME "SA_EN")
		schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1.25:car(cdr(POINT))-20 "R0" )
		; Create PRE
		sprintf(NET_NAME "PRE")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "PRE" )	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT)-1.5:car(cdr(POINT))-20) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1.5:car(cdr(POINT))-20 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
		; PIN PRE
		PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
		sprintf(PIN_NAME "PRE")
		schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1.5:car(cdr(POINT))-20 "R0" )
		; Create SA_IN<1:B> for RRAM
		sprintf(NET_NAME "VBL1")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "SA_IN<1:%d>" B)	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT):car(cdr(POINT))-21) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-21 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
		; Create SA_IN<B+1:2*B> for REF
		sprintf(NET_NAME "VBL2")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "SA_IN<%d:%d>" B+1 2*B)	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT):car(cdr(POINT))-21) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))-21 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
		; Create SA_VO<1:B>
		sprintf(NET_NAME "VO1")	
		DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
		POINT = calculatePinPosition(DB_PIN)	
		sprintf(NET_NAME "SA_VO<1:%d>" B)	
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT))-20 car(POINT)-1:car(cdr(POINT))-20) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT))-20 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )		
		; PIN SA_VO<1:B>
		;PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
		;sprintf(PIN_NAME "SA_VO<1:%d>" B)	
		;schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT)-1:car(cdr(POINT))-20 "R0" )	
	) ; if
	;-------------------------------------------------------------------------------------------------------------------------------

	;-------------------------------------------------------------------------------------------------------------------------------
	; Create MUX block for SA
	sprintf(NAME "MUX_BLOCK_%d" B) 
	MASTER_CV = dbOpenCellViewByType( LIBRARY NAME "symbol" "" "r")	
	dbCreateInst(CELLVIEW MASTER_CV "MUX_BLOCK<1:2>" list(5 -20) "R0")
	; Create READ
	sprintf(NET_NAME "EN")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "READ")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-20 car(POINT)+4:car(cdr(POINT))-20) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+4:car(cdr(POINT))-20 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN READ
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "READ")
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)+4:car(cdr(POINT))-20 "R0" )	
	; Create NOT_READ
	sprintf(NET_NAME "NOT_EN")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "NOT_READ")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-20 car(POINT)+4.25:car(cdr(POINT))-20) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+4.25:car(cdr(POINT))-20 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN NOT_READ
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "NOT_READ")
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)+4.25:car(cdr(POINT))-20 "R0" )	
	; Create VSS
	sprintf(NET_NAME "VSS")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-20 car(POINT)+5:car(cdr(POINT))-18) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-18 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VDD
	sprintf(NET_NAME "VDD")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDD")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-20 car(POINT)+5:car(cdr(POINT))-18.25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-18.25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create P_OUT<1:2B>
	sprintf(NET_NAME "OUT<1:%d>" B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P_OUT<1:%d>" 2*B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-20 car(POINT)+5:car(cdr(POINT))-18.5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-18.5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create SA_IN<1:2B>
	sprintf(NET_NAME "BL<1:%d>" B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "SA_IN<1:%d>" 2*B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-20 car(POINT)+5:car(cdr(POINT))-18.75) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-18.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	;---------------------------------------------------------------------------------------------------------------------------------------
	
	; DO IT IN DIGITAL DESIGN
	;---------------------------------------------------------------------------------------------------------------------------------------
	; Create Instance WR OUT ARRAY
	MASTER_CV = dbOpenCellViewByType("THESIS" "TG" "symbol" "" "r")
	sprintf(INST_NAME "WR_OUT_SW<1:%d>" B) 	
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(5 -25) "R0")
	; Create WR_IN<1:B>
	sprintf(NET_NAME "IN" B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WR_IN<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-25 car(POINT)+4:car(cdr(POINT))-25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+4:car(cdr(POINT))-25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create Z_WR<1:B>
	sprintf(NET_NAME "OUT" B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "Z_WR<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-25 car(POINT)+6:car(cdr(POINT))-25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+6:car(cdr(POINT))-25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN Z_WR<1:B>
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "Z_WR<1:%d>" B)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT)+6:car(cdr(POINT))-25 "R0" )	
	; Create WRITE
	sprintf(NET_NAME "S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "WRITE")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-25 car(POINT)+5:car(cdr(POINT))-26) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-26 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create NOT_WRITE
	sprintf(NET_NAME "NOT_S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "NOT_WRITE")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-25 car(POINT)+5:car(cdr(POINT))-24) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-24 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VDDL
	sprintf(NET_NAME "VDD")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDL")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-25 car(POINT)+5:car(cdr(POINT))-24) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-24 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VSS
	sprintf(NET_NAME "VSS")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+5:car(cdr(POINT))-25 car(POINT)+5:car(cdr(POINT))-26) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+5:car(cdr(POINT))-26 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	;----------------------------------------------------------------------------------------------------------------------------------

	;---------------------------------------------------------------------------------------------------------------------------------------
	; Create Instance SA OUT ARRAY
	MASTER_CV = dbOpenCellViewByType("THESIS" "TG" "symbol" "" "r")
	sprintf(INST_NAME "SA_OUT_SW<1:%d>" B) 	
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(10 -25) "R0")
	; Create SA_VO<1:B>
	sprintf(NET_NAME "IN" B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "SA_VO<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-25 car(POINT)+9:car(cdr(POINT))-25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+9:car(cdr(POINT))-25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create Z_SA<1:B>
	sprintf(NET_NAME "OUT" B)	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "Z_SA<1:%d>" B)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-25 car(POINT)+11:car(cdr(POINT))-25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+11:car(cdr(POINT))-25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; PIN Z_SA<1:B>
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "Z_SA<1:%d>" B)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT)+11:car(cdr(POINT))-25 "R0" )	
	; Create READ
	sprintf(NET_NAME "S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "READ")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-25 car(POINT)+10:car(cdr(POINT))-26) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-26 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create NOT_READ
	sprintf(NET_NAME "NOT_S")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "NOT_READ")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-25 car(POINT)+10:car(cdr(POINT))-24) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-24 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VDDL
	sprintf(NET_NAME "VDD")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDL")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-25 car(POINT)+10:car(cdr(POINT))-24) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-24 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create VSS
	sprintf(NET_NAME "VSS")	
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)+10:car(cdr(POINT))-25 car(POINT)+10:car(cdr(POINT))-26) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)+10:car(cdr(POINT))-26 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	
	
	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
