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
									DX				; HORIZONTAL PITCH
									DY				; VERTICAL PITCH
								)



	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL			
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME			
			DB_RRAM_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			DB_REF_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF RRAM LAYOUT CELL
			NET_ID_VSS	; VARIABLE TO HOLD VSS NET ID
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB				
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
	; PLACE RRAM ARRAY
	sprintf(NAME "REF_%d_%d" B Y)
	DB_REF_CELL_LAYOUT = dbOpenCellViewByType(DB_REF_CELL~>libName DB_REF_CELL~>cellName "layout" "maskLayout" "r")
	dbCreateInst(CELLVIEW DB_REF_CELL_LAYOUT  NAME list(X*DX 0) "R0")

	; STEP 4
	; PLACE GUARD RING
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(-0.5:-3.03 (X+B)*DX+1.205+0.5:-2.53-0.5 (X+B)*DX+1.205+0.5:Y*DY+1.78+0.75-2.28+0.5 -1.205-0.5:Y*DY+1.78+0.75-2.28+0.5 -1.205-0.5:0.5-2.28+0.5 ) ?netName "VSS")
	CCSdrawMPPUsingTemplate("PSubGuardring" ?cvId CELLVIEW ?pts list(-1.205-0.5:0.92-2.28+0.5 -1.205-0.5:-0.25-2.28-0.5 0.42-0.5:-0.25-2.28-0.5)  ?netName "VSS")


	)	;prog
)	;PROCEDURE
