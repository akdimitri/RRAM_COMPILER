;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			1/08/2021
; Description:	This file contains the main function SKILL code to create testbench for RRAM
; Version:		1
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	characterizeRRAMmixedsch(					; LIST OF ARGUMENTS
								X 					; X SIZE OF ARRAY (COLS)
								Y					; Y SIZE OF ARRAY (ROWS)
								B					; B (BITS) SIZE OF A WORD
								LIBRARY				; LIBRARY TO PLACE THE NEW DESIGN
								NAME					; NAME OF THE CELLVIEW
								DB_TOP			; DB OF ANALOG RRAM SCH
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
				TEMP
			)			; END OF LIST OF LOCAL VARIABLES
	

		printf("+++ Creating Schematic for Testbench Mixed RRAM +++\n")


	; Create Schematic View
	CELLVIEW = dbOpenCellViewByType( LIBRARY NAME "schematic" "schematic" "w")	



	; Create Instance Controller	
	MASTER_CV = dbOpenCellViewByType(DB_TOP~>libName DB_TOP~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "TOP" list(0 0) "R0")

	; LEFT PINS
	; EN
	sprintf(NET_NAME "EN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	;sprintf(NET_NAME "EN")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; RW
	sprintf(NET_NAME "RW")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	;sprintf(NET_NAME "EN")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; X_ADDRESS_IN<X_SIZE-1:0>
	sprintf(NET_NAME "X_ADDRESS_IN<%d:0>" int(log(X/B)/log(2))-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	;sprintf(NET_NAME "EN")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Y_ADDRESS_IN<Y_SIZE-1:0>
	sprintf(NET_NAME "Y_ADDRESS_IN<%d:0>" int(log(Y)/log(2))-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)		
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; clk
	sprintf(NET_NAME "clk")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	;sprintf(NET_NAME "EN")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; reset
	sprintf(NET_NAME "reset")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	;sprintf(NET_NAME "EN")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT)-1:car(cdr(POINT))) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-1:car(cdr(POINT)) NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; TOP PINS
	; Z_BUS
	sprintf(NET_NAME "Z_BUS<%d:0>" B-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)		
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	; gnd!
	sprintf(NET_NAME "VSS")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "gnd!")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	; VDDW
	sprintf(NET_NAME "VDDW")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	; VDDH
	sprintf(NET_NAME "VDDH")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	; VDDL
	sprintf(NET_NAME "VDDL")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	; TOP PINS
	; P
	sprintf(NET_NAME "P<0:%d>" X-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)		
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	; TOP PINS
	; MR
	sprintf(NET_NAME "MR<0:%d>" X*Y-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)		
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT):car(cdr(POINT)) car(POINT):car(cdr(POINT))+1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT):car(cdr(POINT))+1 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )


	; CREATE CLOCK
	MASTER_CV = dbOpenCellViewByType("analogLib" "vpulse" "symbol" "" "r")			
	dbCreateParamInst(CELLVIEW MASTER_CV  "VCLK" list(-2 2) "R0" 1 list(
						list("v2" "string" "5") 
						list("per" "string" "CLK") 
						list("pw" "string" "CLK/2") 
						list("tr" "string" "200p") 
						list("tf" "string" "200p") 
						)
						)
	
	schCreateWire( CELLVIEW "draw" "full" list(-2:1.375 -2:1.625) 0.0625 0.0625 0.0 )	
	MASTER_CV = dbOpenCellViewByType("analogLib" "gnd" "symbol" "" "r")
	dbCreateParamInst(CELLVIEW MASTER_CV  "" list(-2, 1.375) "R0" 1)	

	
	sprintf(NET_NAME "clk")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-2:2 -2:2.315) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -2:2.315 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; VDDH
	MASTER_CV = dbOpenCellViewByType("analogLib" "vdc" "symbol" "" "r")
	dbCreateParamInst(CELLVIEW MASTER_CV  "V1" list(-2.5 2) "R0" 1 list(
						list("vdc" "string" "VDDH") 						
						)
						)
	schCreateWire( CELLVIEW "draw" "full" list(-2.5:1.375 -2.5:1.625) 0.0625 0.0625 0.0 )	
	MASTER_CV = dbOpenCellViewByType("analogLib" "gnd" "symbol" "" "r")
	dbCreateParamInst(CELLVIEW MASTER_CV  "" list(-2.5, 1.375) "R0" 1)	
	
	sprintf(NET_NAME "VDDH")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-2.5:2 -2.5:2.315) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -2.5:2.315 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; VDDL
	MASTER_CV = dbOpenCellViewByType("analogLib" "vdc" "symbol" "" "r")
	dbCreateParamInst(CELLVIEW MASTER_CV  "V2" list(-3 2) "R0" 1 list(
						list("vdc" "string" "VDDL") 						
						)
						)
	schCreateWire( CELLVIEW "draw" "full" list(-3:1.375 -3:1.625) 0.0625 0.0625 0.0 )	
	MASTER_CV = dbOpenCellViewByType("analogLib" "gnd" "symbol" "" "r")
	dbCreateParamInst(CELLVIEW MASTER_CV  "" list(-3, 1.375) "R0" 1)	
	
	sprintf(NET_NAME "VDDL")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-3:2 -3:2.315) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -3:2.315 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; VDDW
	MASTER_CV = dbOpenCellViewByType("analogLib" "vdc" "symbol" "" "r")
	dbCreateParamInst(CELLVIEW MASTER_CV  "V3" list(-3.5 2) "R0" 1 list(
						list("vdc" "string" "VDDW") 						
						)
						)
	schCreateWire( CELLVIEW "draw" "full" list(-3.5:1.375 -3.5:1.625) 0.0625 0.0625 0.0 )	
	MASTER_CV = dbOpenCellViewByType("analogLib" "gnd" "symbol" "" "r")
	dbCreateParamInst(CELLVIEW MASTER_CV  "" list(-3.5, 1.375) "R0" 1)	
	
	sprintf(NET_NAME "VDDW")
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-3.5:2 -3.5:2.315) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) -3.5:2.315 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )


	; Create Instance Test Signals
	sprintf(TEMP "TEST_SIGNALS_%d_%d_%d" X Y B)
	MASTER_CV = dbOpenCellViewByType("THESIS" TEMP  "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "TEST_SIGNALS" list(-5 -1) "R0")

	; LEFT PINS
	; clk
	sprintf(NET_NAME "clk")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)		
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-1 car(POINT)-1-5:car(cdr(POINT))-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5-1:car(cdr(POINT))-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; RIGHT PINS
	; EN
	sprintf(NET_NAME "EN")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-1 car(POINT)+1-5:car(cdr(POINT))-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; RW
	sprintf(NET_NAME "RW")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-1 car(POINT)+1-5:car(cdr(POINT))-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; reset
	sprintf(NET_NAME "reset")
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-1 car(POINT)+1-5:car(cdr(POINT))-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; X_ADDRESS_IN
	sprintf(NET_NAME "X_ADDRESS_IN<%d:0>" int(log(X/B)/log(2))-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-1 car(POINT)+1-5:car(cdr(POINT))-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Y_ADDRESS_IN
	sprintf(NET_NAME "Y_ADDRESS_IN<%d:0>" int(log(Y)/log(2))-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-1 car(POINT)+1-5:car(cdr(POINT))-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Y_ADDRESS_IN
	sprintf(NET_NAME "Z_WR<%d:0>" B-1)
	DB_PIN = setof(TERM MASTER_CV~>terminals TERM~>name==NET_NAME)
	POINT = calculatePinPosition(DB_PIN)	
	sprintf(NET_NAME "Z_BUS<%d:0>" B-1)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(car(POINT)-5:car(cdr(POINT))-1 car(POINT)+1-5:car(cdr(POINT))-1) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) car(POINT)-5+1:car(cdr(POINT))-1 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )







	
	; Write Resistor
	MASTER_CV = dbOpenCellViewByType("analogLib" "res" "symbol" "" "r")
	sprintf(INST_NAME "WRITE_R<1:%d>" B)
	dbCreateParamInst(CELLVIEW MASTER_CV  INST_NAME list(3 2) "R0" 1 list(
						list("r" "string" "1M") 						
						)
						)
	sprintf(NET_NAME "MR<%d:%d>" X*Y-2*B X*Y-1-B)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(3:2 3:2.375) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) 3:2.375 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	sprintf(NET_NAME "P<%d:%d>" X-2*B X-1-B)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(3:1.31 3:1.625) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) 3:1.31 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )

	
	; Read Resistor
	for( j 1 B
		MASTER_CV = dbOpenCellViewByType("analogLib" "res" "symbol" "" "r")
		sprintf(INST_NAME "READ_R<%d>" j)
		if( mod(j,2)==0 
			then
				sprintf(TEMP "Re")
			else
				sprintf(TEMP "Ro")
		)
		
		dbCreateParamInst(CELLVIEW MASTER_CV  INST_NAME list(3.5+(j-1)*0.5 2) "R0" 1 list(
							list("r" "string" TEMP) 						
							)
							)
		sprintf(NET_NAME "MR<%d>" X*Y-B+j-1)
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(3.5+(j-1)*0.5:2 3.5+(j-1)*0.5:2.375) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) 3.5+(j-1)*0.5:2.375 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )
	
		sprintf(NET_NAME "P<%d>" X-B+j-1)
		NET_ID = schCreateWire( CELLVIEW "draw" "full" list(3.5+(j-1)*0.5:1.31 3.5+(j-1)*0.5:1.625) 0.0625 0.0625 0.0 )	
		schCreateWireLabel( CELLVIEW car(NET_ID) 3.5+(j-1)*0.5:1.31 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )
	)

	; No Connect
	MASTER_CV = dbOpenCellViewByType("basic" "noConn" "symbol" "" "r")	
	sprintf(INST_NAME "NC<1:%d>" X-2*B)
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(3 0) "R0")
	sprintf(NET_NAME "P<0:%d>" X-2*B-1)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(3:0 3:0.37) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) 3:0.37 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )
	
	; No Connect
	MASTER_CV = dbOpenCellViewByType("basic" "noConn" "symbol" "" "r")	
	sprintf(INST_NAME "NC_2<1:%d>" X*Y-2*B)
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(4 0) "R0")
	sprintf(NET_NAME "MR<0:%d>" X*Y-2*B-1)
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(4:0 4:0.37) 0.0625 0.0625 0.0 )	
	schCreateWireLabel( CELLVIEW car(NET_ID) 4:0.37 NET_NAME "upperCenter" "R90" "fixed" 0.05 nil )
	


	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	

	)	; prog
)	; procedure
