;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			18/02/2021
; Description:	This file contains the SKILL to load SKILL scripts for RRAM COMPILER
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	loadRRAMCompiler(				; PROCEDURE ARGUMENTS
							@key 
							(PATH	"./SKILL/RRAM_COMPILER")	; PATH TO RRAM COMPILER							
							)				; END  OF PRCEDURE ARGUMENTS

prog(	(		; LOCAL VARIABLE DECLARATION
		FILE		; TEMPORARY VARABLE TO HOLD THE NAME OF THE FILE TO BE CALLED
		)		; END OF LOCAL VARIABLE DECLARATION	

	sprintf(FILE "%s/%s" PATH "createRRAM.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAM.il")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "createRRAMsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAMsch.il")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "createRRAMlayout.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAMlayout.il")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "CCSdrawMPPUsingTemplate.ils")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING CCSdrawMPPUsingTemplate.ils ")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "runDRC_Calibre.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING runDRC_Calibre.il ")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "runLVS_Calibre.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING runLVS_Calibre.il ")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "runPEX_Calibre.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING runPEX_Calibre.il ")
		return(-1)
	)

	return(t)
)	; prog
)	; procedure
