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
						)
	prog( 	(			; LIST OF LOCAL VARIABLES
				CELLVIEW		; DB OF CELLVIEW
				INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME
				MASTER_CV	; DB OF CELLVIEW
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

	; Create Instance RRAM ARRAY	
	MASTER_CV = dbOpenCellViewByType(DB_RRAM_SCH~>libName DB_RRAM_SCH~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV  "RRAM" list(0 0) "R0")

	; Create Instance PMUX ARRAY	
	MASTER_CV = dbOpenCellViewByType(DB_PMUX_SCH~>libName DB_PMUX_SCH~>cellName "symbol" "" "r")		
	dbCreateInst(CELLVIEW MASTER_CV "PMUX" list(0 -5) "R0")
	
	; Create Instance NMUX ARRAY		
	MASTER_CV =	dbOpenCellViewByType(DB_NMUX_SCH~>libName DB_NMUX_SCH~>cellName "symbol" "" "r")
	dbCreateInst(CELLVIEW  MASTER_CV "NMUX" list(0 -10) "R0")

	; Create Instance REF ARRAY	
	MASTER_CV =	dbOpenCellViewByType(DB_REF_SCH~>libName DB_REF_SCH~>cellName "symbol" "" "r")	
	dbCreateInst(CELLVIEW MASTER_CV "REF" list(5 0) "R0")

	; Create Instance SA ARRAY	
	MASTER_CV = dbOpenCellViewByType(DB_SA~>libName DB_SA~>cellName "symbol" "" "r")
	sprintf(INST_NAME "SA<1:%d>" B) 	
	dbCreateInst(CELLVIEW MASTER_CV  INST_NAME list(0 -20) "R0")

	; Create Nets
	; VSS
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.6875:0.6875 0.6875:2) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.6875:2 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P net. P<1:X>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:0.6875 0.8125:1.75) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<1:%d>" X)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.8125:1.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create N net. N<1:X>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.9375:0.6875 0.9375:1.5) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N<1:%d>" X)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.9375:1.5  NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )	

	; Create SEL net. SEL<1:Y>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.625:0 0:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "SEL<1:%d>" Y)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.625:0  NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create MR<1:XY>
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.0625:0.6875 1.0625:1.25) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "MR<1:%d>" X*Y)	; MR row representation
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.0625:1.25 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create SEL net. SEL<1:Y> FOR REF
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(4.5:0 5:0) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "SEL<1:%d>" Y)	; Columns share P
	schCreateWireLabel( CELLVIEW car(NET_ID) 4.5:0  NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )
	
	; Create P net. P<X+1:X+B> FOR REF
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(5.8125:0.625 5.8125:2) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<%d:%d>" X+1 X+B)	; REF COL
	schCreateWireLabel( CELLVIEW car(NET_ID) 5.8125:2 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; VSS on N REF
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(5.9375:0.625 5.9375:1.5) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 5.9375:1.5 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P ENABLE net. P<1:(X+B)/B> FOR P MUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-1:-5 0:-5) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P_EN<1:%d>" (X+B)/B)	; REF COL
	schCreateWireLabel( CELLVIEW car(NET_ID) -1:-5 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P NOT ENABLE net. P<1:(X+B)/B> FOR P MUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.75:-5.125 0:-5.125) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P_NOT_EN<1:%d>" (X+B)/B)	; REF COL
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.75:-5.125 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; VSS on PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:-4.3125 0.8125:-3.25) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.8125:-3.5 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; VSS on PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.9375:-4.3125 0.9375:-3.5) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.9375:-3.25 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )

	; OUT to SA/WR PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.0625:-4.3125 1.0625:-3.75) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P_OUT<1:%d>" B)	
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.0625:-3.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; BL to P lines RRAM ARRAY PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.1875:-4.3125 1.1875:-4) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "P<1:%d>" X+B)
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.1875:-4 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create N ENABLE net. N<1:(X+B)/B> FOR P MUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-1:-10 0:-10) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N_EN<1:%d>" X/B)	; REF COL
	schCreateWireLabel( CELLVIEW car(NET_ID) -1:-10 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; Create P NOT ENABLE net. P<1:(X+B)/B> FOR P MUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(-0.75:-10.125 0:-10.125) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N_NOT_EN<1:%d>" X/B)	; REF COL
	schCreateWireLabel( CELLVIEW car(NET_ID) -0.75:-10.125 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; VSS on PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.8125:-9.3125 0.8125:-8.25) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.8125:-8.5 "VSS" "upperCenter" "R0" "fixed" 0.05 nil )

	; VSS on PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(0.9375:-9.3125 0.9375:-8.5) 0.0625 0.0625 0.0 )
	schCreateWireLabel( CELLVIEW car(NET_ID) 0.9375:-8.25 "VDD" "upperCenter" "R0" "fixed" 0.05 nil )

	; OUT to SA/WR PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.0625:-9.3125 1.0625:-8.75) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N_OUT<1:%d>" B)	
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.0625:-8.75 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	; BL to N lines RRAM ARRAY PMUX
	NET_ID = schCreateWire( CELLVIEW "draw" "full" list(1.1875:-9.3125 1.1875:-9) 0.0625 0.0625 0.0 )
	sprintf(NET_NAME "N<1:%d>" X)
	schCreateWireLabel( CELLVIEW car(NET_ID) 1.1875:-9 NET_NAME "upperCenter" "R0" "fixed" 0.05 nil )

	



	schCheck(CELLVIEW)		; Check 
	dbSave(CELLVIEW)			; Save
	return(CELLVIEW)			; return cellview db value

	)	; prog
)	; procedure
