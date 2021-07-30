;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			23/07/2021
; Description:	This file contains the SKILL function to generate the mixed signal design of a RRAM
;-------------------------------------------------------------------------------------------------------------------------------------------- 
procedure( createRRAMmixed(		; LIST OF ARGUMENTS
						M		; NUMBER OF COLUMNS X
						N		; NUMBER OF ROWS Y						
						B		; BITS OF A WORD B
						@optional
						(LIBRARY "THESIS")
						)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
			FILE			; TEMPORARY VARIABLE TO HOLD PATH TO A FILE	
			NAME			;	
			DB_ANALOG			; DB OF ANALOG RRAM SCH
			DB_CONTROLLER		; DB OF DIGITAL CONTROLLER
			DB_SIGNALS_VDDL		; DB OF DIGITAL VDDL SIGNALS
			)			; END OF LIST OF LOCAL VARIABLES

	printf("\n\n\n")
	printf("###############################\n")
	printf("####### RRAM COMPILER #########\n")
	printf("###############################\n")
	printf("# AUTHOR: DIMITRIS ANTONIADIS #\n")
	printf("# IMPERIAL COLLEGE LONDON     #\n")
	printf("# VERSION DATE: 26/07/2021    #\n")
	printf("###############################")
	; STEP 1 CREATE ANALOG PART
	DB_ANALOG = createRRAManalog( M N B)
	; STEP 2 CREATE DIGITAL PART
	generateDigital(	M N B)
	;STEP 3 STREAM IN TO VIRTUOSO
	sprintf(NAME "CONTROLLER_5V_%d_%d_%d" M N B)
	sprintf(FILE "./DIGITAL/innovus/%s/outputs/%s_final.gds" NAME NAME)
	;my_streamIn(FILE "tcb018bcdgp2a")
	my_streamIn(FILE "DIGITAL_THESIS_5V")
	sprintf(NAME "SIGNALS_VDDL_%d_%d_%d" M N B)
	sprintf(FILE "./DIGITAL/innovus/%s/outputs/%s_final.gds" NAME NAME)
	;my_streamIn(FILE "tcb018gbwp7t")
	my_streamIn(FILE "DIGITAL_THESIS_1_8V")

	; STEP 4 VERILOGIN
	sprintf(NAME "CONTROLLER_5V_%d_%d_%d" M N B)
	sprintf(FILE "./DIGITAL/innovus/%s/outputs/%s_final_pg_top.v" NAME NAME)
	my_verilogIn( FILE "tcb018bcdgp2a" "DIGITAL_THESIS_5V")
	;createAMSconfig("DIGITAL_THESIS_5V" NAME "DIGITAL_THESIS_5V THESIS basic analogLib tcb018bcdgp2a DIMITRIS_CELL tsmc18" )

	sprintf(NAME "SIGNALS_VDDL_%d_%d_%d" M N B)
	sprintf(FILE "./DIGITAL/innovus/%s/outputs/%s_final_pg_top.v" NAME NAME)
	my_verilogIn( FILE "tcb018gbwp7t" "DIGITAL_THESIS_1_8V")
	;createAMSconfig("DIGITAL_THESIS_1_8V" NAME "DIGITAL_THESIS_1_8V THESIS basic analogLib tcb018gbwp7t DIMITRIS_CELL tsmc18" )
	ddUpdateLibList()

	

	; STEP 5 
	; TOP LEVEL SCHEMATIC
	sprintf(NAME "CONTROLLER_5V_%d_%d_%d" M N B)
	DB_CONTROLLER = dbOpenCellViewByType("DIGITAL_THESIS_5V" NAME "symbol" "" "r")
	sprintf(NAME "SIGNALS_VDDL_%d_%d_%d" M N B)
	DB_SIGNALS_VDDL = dbOpenCellViewByType("DIGITAL_THESIS_1_8V" NAME "symbol" "" "r")
	
	sprintf(NAME "TOP_%d_%d_%d" M N B)
	createRRAMmixedsch( M N B LIBRARY NAME DB_ANALOG DB_CONTROLLER DB_SIGNALS_VDDL)

	; STEP 6
	;TOP LEVEL SYMBOL
	; Create Symbol
	PIN_LIST=schSchemToPinList(LIBRARY NAME "schematic")
	schPinListToView(LIBRARY NAME "symbol" PIN_LIST "schPinListToSymbolGen")
	createAMSconfig(LIBRARY NAME "DIGITAL_THESIS_5V THESIS DIGITAL_THESIS_1_8V basic analogLib tcb018bcdgp2a tcb018gbwp7t DIMITRIS_CELL tsmc18" )

	; STEP 7
	; TOP LAYOUT
	createRRAMmixedlayout(M N B LIBRARY NAME DB_ANALOG DB_CONTROLLER DB_SIGNALS_VDDL)

	return(t)	
	)	; prog
)	; procedure
