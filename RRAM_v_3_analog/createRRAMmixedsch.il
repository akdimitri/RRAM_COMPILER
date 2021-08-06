;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			25/07/2021
; Description:	This file contains the main function SKILL code to create the RRAM Schematic
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	createRRAMmixedsch(					; LIST OF ARGUMENTS
							X 					; X SIZE OF ARRAY (COLS)
							Y					; Y SIZE OF ARRAY (ROWS)
							B					; B (BITS) SIZE OF A WORD
							LIBRARY				; LIBRARY TO PLACE THE NEW DESIGN
							NAME					; NAME OF THE CELLVIEW
							DB_ANALOG			; DB OF ANALOG RRAM SCH
							DB_CONTROLLER		; DB OF DIGITAL CONTROLLER
							DB_SIGNALS_VDDL		; DB OF DIGITAL VDDL SIGNALS
						)
	prog( 	(			; LIST OF LOCAL VARIABLES
				CELLVIEW		; DB OF CELLVIEW
				INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
				MASTER_CV	; DB OF CELLVIEW
				DB_PIN
				POINT
				TERM				
				NET_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF THE NET
				NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
				PIN_CV_ID	; TEMPORARY VARIABLE TO HOLD THE DB OF THE PIN				
				PIN_NAME		; TEMPORARY VARIABLE TO HOLD THE NAME OF A PIN
				X_SIZE
				Y_SIZE
			)			; END OF LIST OF LOCAL VARIABLES
	

		printf("+++ Creating Schematic for Mixed RRAM +++\n")


	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	
	
	; Create Instance Controller	
	MASTER_CV = dbOpenCellViewByType(DB_CONTROLLER~>libName DB_CONTROLLER~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "CONTROLLER" list(-5 0) "R0")

	; Connections for CONTROLLER
	; Create VDD
	sprintf(NET_NAME "VDD")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDH")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; X_ADDRESS_IN PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "VDDH")	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT)+1-5:car(cdr(POINT)) "R0" )	

	; Create VSS
	sprintf(NET_NAME "VSS")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; X_ADDRESS_IN PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "VSS")	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT)+1-5:car(cdr(POINT)) "R0" )	
	
	; Create X_ADDRESS_IN<X_SIZE-1:0>	
	X_SIZE = int(log(float(X)/float(B))/log(2))
	sprintf(NET_NAME "X_ADDRESS_IN<%d:0>" X_SIZE-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)-1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; X_ADDRESS_IN PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "X_ADDRESS_IN<%d:0>" X_SIZE-1)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1-5:car(cdr(POINT)) "R0" )	

	; Create Y_ADDRESS_IN<Y_SIZE-1:0>
	Y_SIZE = int(log(Y)/log(2))
	sprintf(NET_NAME "Y_ADDRESS_IN<%d:0>" Y_SIZE-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)-1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; X_ADDRESS_IN PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "Y_ADDRESS_IN<%d:0>" Y_SIZE-1)	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1-5:car(cdr(POINT)) "R0" )	

	; Create EN
	sprintf(NET_NAME "EN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)-1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; X_ADDRESS_IN PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "EN")	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1-5:car(cdr(POINT)) "R0" )	

	; Create RW
	sprintf(NET_NAME "RW")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)-1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; RW PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "RW")	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1-5:car(cdr(POINT)) "R0" )	

	; Create clk
	sprintf(NET_NAME "clk")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)-1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; clk PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "clk")	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1-5:car(cdr(POINT)) "R0" )	

	; Create reset
	sprintf(NET_NAME "reset")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)-1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; reset PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "ipin" "symbol" "" 'r )
	sprintf(PIN_NAME "reset")	
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "input" nil car(POINT)-1-5:car(cdr(POINT)) "R0" )	

	; Create P_EN<X/B:0>
	sprintf(NET_NAME "P_EN<%d:0>" X/B)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create P_NOT_EN<X/B:0>
	sprintf(NET_NAME "P_NOT_EN<%d:0>" X/B)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create N_EN<X/B-1:0>
	sprintf(NET_NAME "N_EN<%d:0>" X/B-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Create N_NOT_EN<X/B-1:0>
	sprintf(NET_NAME "N_NOT_EN<%d:0>" X/B-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create SEL<Y:0>
	sprintf(NET_NAME "SEL<%d:0>" Y-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create READ_H
	sprintf(NET_NAME "READ")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create WRITE_H
	sprintf(NET_NAME "WRITE")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create WRITE_H_2
	sprintf(NET_NAME "WRITE_2")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_2_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_WRITE_H
	sprintf(NET_NAME "NOT_WRITE")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_WRITE_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create WRITE_H_2
	sprintf(NET_NAME "NOT_WRITE_2")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_WRITE_2_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create DVLP
	sprintf(NET_NAME "DVLP")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "DVLP_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create PRE
	sprintf(NET_NAME "PRE")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "PRE_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create EN_SA
	sprintf(NET_NAME "EN_SA")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT)) car(POINT)+1-5:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "SA_EN_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )


	; Create Leveldown shifters	
	MASTER_CV = dbOpenCellViewByType("THESIS" "LEVEL_DOWN_SIGNALS" "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "LEVEL_DOWN" list(-13 -5) "R0")

	; Create VDD
	sprintf(NET_NAME "VDD")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDL")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-13:car(cdr(POINT))-5+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13:car(cdr(POINT))-5+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VSS
	sprintf(NET_NAME "VSS")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-13:car(cdr(POINT))-5-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13:car(cdr(POINT))-5-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )


	; Create DVLP
	sprintf(NET_NAME "DVLP_H_IN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-1-13:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "DVLP_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create PRE
	sprintf(NET_NAME "PRE_H_IN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-1-13:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "PRE_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create READ_H
	sprintf(NET_NAME "READ_VDDH_IN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-1-13:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create SA_EN_H
	sprintf(NET_NAME "SA_EN_H_IN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-1-13:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "SA_EN_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create WRITE_H
	sprintf(NET_NAME "WRITE_VDDH_IN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-1-13:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_2_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create DVLP_BUF
	sprintf(NET_NAME "DVLP_H_OUT")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-13+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "DVLP_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create DVLP_BUF
	sprintf(NET_NAME "PRE_H_OUT")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-13+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "PRE_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create READ_BUF
	sprintf(NET_NAME "READ_VDDH_OUT")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-13+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create SA_EN_H
	sprintf(NET_NAME "SA_EN_H_OUT")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-13+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "SA_EN_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create WRITE_BUF
	sprintf(NET_NAME "WRITE_VDDH_OUT")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-13:car(cdr(POINT))-5 car(POINT)-13+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-13+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )


	; Create Instance Signals	
	MASTER_CV = dbOpenCellViewByType(DB_SIGNALS_VDDL~>libName DB_SIGNALS_VDDL~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "SIGNALS_VDDL" list(-5 -5) "R0")

	; Create WRITE_BUF
	sprintf(NET_NAME "WRITE_VDDH")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5-1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create WRITE_BUF
	sprintf(NET_NAME "READ_VDDH")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5-1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create DVLP_BUF
	sprintf(NET_NAME "DVLP_H")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5-1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "DVLP_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create PRE_BUF
	sprintf(NET_NAME "PRE_H")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5-1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "PRE_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create SA_EN_BUF
	sprintf(NET_NAME "SA_EN_H")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5-1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "SA_EN_BUF")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create dummy_en
	sprintf(NET_NAME "dummy_en")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5-1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "VDDL")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create WRITE_L
	sprintf(NET_NAME "WRITE_VDDL")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_WRITE_L
	sprintf(NET_NAME "NOT_WRITE_VDDL")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_WRITE_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create READ_L_1
	sprintf(NET_NAME "READ_VDDL_1")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_L_1")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_READ_L_1
	sprintf(NET_NAME "NOT_READ_VDDL_1")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_READ_L_1")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create READ_L_2
	sprintf(NET_NAME "READ_VDDL_2")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_L_2")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_READ_L_1
	sprintf(NET_NAME "NOT_READ_VDDL_2")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_READ_L_2")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create DVLP_L
	sprintf(NET_NAME "DVLP_L")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "DVLP_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create PRE_L
	sprintf(NET_NAME "PRE_L")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "PRE_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create PRE_L
	sprintf(NET_NAME "SA_EN_L")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "SA_EN_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create Z_SA
	sprintf(NET_NAME "Z_SA<%d:0>" B-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "Z_SA<%d:0>" B-1)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create Z_WR
	;sprintf(NET_NAME "Z_WR<%d:0>" B-1)
	;DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	;POINT = calculatePinPosition(DB_PIN)	
	;NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	;sprintf(NET_NAME "Z_WR<%d:0>" B-1)
	;schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create Z_BUS
	sprintf(NET_NAME "Z_BUS<%d:0>" B-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "Z_BUS<%d:0>" B-1)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; Z_BUS PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "Z_BUS<%d:0>" B-1)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT)-5+1:car(cdr(POINT))-5 "R0" )	
	
	; Create VDD
	sprintf(NET_NAME "VDD")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDL")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VSS
	sprintf(NET_NAME "VSS")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-5 car(POINT)-5+1:car(cdr(POINT))-5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create Instance RRAM Analog
	MASTER_CV = dbOpenCellViewByType(DB_ANALOG~>libName DB_ANALOG~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "RRAM_ANALOG" list(0 0) "R0")

	; Create Z_SA
	sprintf(NET_NAME "Z_SA<1:%d>" B)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "Z_SA<0:%d>" B-1)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create Z_WR
	sprintf(NET_NAME "Z_WR<1:%d>" B)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "Z_BUS<0:%d>" B-1)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VSS
	sprintf(NET_NAME "VSS")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VSS")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create VDDW
	sprintf(NET_NAME "VDDW")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDW")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+2.5) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+2.5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; VDDW PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "VDDW")
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT):car(cdr(POINT))+2.5 "R0" )

	; Create VDDL
	sprintf(NET_NAME "VDDL")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDL")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+2.25) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+2.25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; VDDL PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "VDDL")
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT):car(cdr(POINT))+2.25 "R0" )	

	; Create VDD
	sprintf(NET_NAME "VDD")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "VDDH")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )


	; Create P<1:X>
	sprintf(NET_NAME "P<1:%d>" X)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "P<0:%d>" X-1)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+2) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+2 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; P PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "P<0:%d>" X-1)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT):car(cdr(POINT))+2 "R0" )	

	; Create MR<1:X*Y>
	sprintf(NET_NAME "MR<1:%d>" X*Y)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "MR<0:%d>" X*Y-1)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1.75) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	; MR PIN
	PIN_CV_ID = dbOpenCellViewByType( "basic" "iopin" "symbol" "" 'r )
	sprintf(PIN_NAME "MR<0:%d>" X*Y-1)
	schCreatePin( CELLVIEW PIN_CV_ID PIN_NAME "inputOutput" nil car(POINT):car(cdr(POINT))+1.75 "R0" )	

	; Create DVLP_L
	sprintf(NET_NAME "DVLP")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "DVLP_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_READ_L_1
	sprintf(NET_NAME "NOT_READ")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_READ_L_1")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_READ_L_1
	sprintf(NET_NAME "NOT_READ_2")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_READ_L_2")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_WRITE_H
	sprintf(NET_NAME "NOT_WRITE_H")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_WRITE_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create NOT_WRITE_L
	sprintf(NET_NAME "NOT_WRITE_L")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "NOT_WRITE_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create N_EN<0:X/B-1>
	sprintf(NET_NAME "N_EN<1:%d>" X/B)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "N_EN<0:%d>" X/B-1)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create N_NOT_EN<0:X/B-1>
	sprintf(NET_NAME "N_NOT_EN<1:%d>" X/B)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "N_NOT_EN<0:%d>" X/B-1)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create PRE_L
	sprintf(NET_NAME "PRE")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "PRE_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P_EN<0:X/B>
	sprintf(NET_NAME "P_EN<1:%d>" X/B+1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "P_EN<0:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P_NOT_EN<0:X/B>
	sprintf(NET_NAME "P_NOT_EN<1:%d>" X/B+1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "P_NOT_EN<0:%d>" X/B)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create READ_L_1
	sprintf(NET_NAME "READ")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_L_1")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create READ_L_2
	sprintf(NET_NAME "READ_2")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "READ_L_2")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create SA_EN_L
	sprintf(NET_NAME "SA_EN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "SA_EN_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create SEL<0:Y-1>
	sprintf(NET_NAME "SEL<1:%d>" Y)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "SEL<0:%d>" Y-1)
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create WRITE_H
	sprintf(NET_NAME "WRITE_H")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_H")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create WRITE_L
	sprintf(NET_NAME "WRITE_L")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	sprintf(NET_NAME "WRITE_L")
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )


	; PLACE RESISTANCES TO BE READ

	

	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
