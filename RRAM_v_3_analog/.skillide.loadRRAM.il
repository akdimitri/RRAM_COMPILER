;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			18/02/2021
; Description:	This file contains the SKILL to load SKILL scripts for RRAM COMPILER
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure(	loadRRAMCompiler(				; PROCEDURE ARGUMENTS
							@key 
							(PATH	"./SKILL/RRAM_COMPILER/RRAM_v_3_analog")	; PATH TO RRAM COMPILER							
							)				; END  OF PRCEDURE ARGUMENTS

prog(	(		; LOCAL VARIABLE DECLARATION
		FILE		; TEMPORARY VARABLE TO HOLD THE NAME OF THE FILE TO BE CALLED
		)		; END OF LOCAL VARIABLE DECLARATION	

	printf("LOAD RRAM COMPILER\n")

	sprintf(FILE "%s/%s" PATH "createRRAM.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAM.il\n")
		return(-1)
	)

	sprintf(FILE "%s/RRAM_Array_Generator/%s" PATH "createRRAMsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAMsch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/RRAM_Array_Generator/%s" PATH "createRRAMlayout.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAMlayout.il\n")
		return(-1)
	)

	sprintf(FILE "%s/misc/%s" PATH "CCSdrawMPPUsingTemplate.ils")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING CCSdrawMPPUsingTemplate.ils\n")
		return(-1)
	)

	sprintf(FILE "%s/Calibre/%s" PATH "runDRC_Calibre.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING runDRC_Calibre.il\n")
		return(-1)
	)

	sprintf(FILE "%s/Calibre/%s" PATH "runLVS_Calibre.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING runLVS_Calibre.il\n")
		return(-1)
	)

	sprintf(FILE "%s/Calibre/%s" PATH "runPEX_Calibre.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING runPEX_Calibre.il\n")
		return(-1)
	)

	sprintf(FILE "%s/RRAM_Array_Generator/%s" PATH "createRRAMrowsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAMrowsch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/RRAM_Array_Generator/%s" PATH "createRRAMrowlayout.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAMrowlayout.il\n")
		return(-1)
	)

	sprintf(FILE "%s/PMUX_Generator/%s" PATH "createPMUXblocksch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createPMUXblocksch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/PMUX_Generator/%s" PATH "createPMUX.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createPMUX.il\n")
		return(-1)
	)

	sprintf(FILE "%s/PMUX_Generator/%s" PATH "createPMUXsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createPMUXsch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/NMUX_Generator/%s" PATH "createNMUXblocksch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createNMUXblocksch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/NMUX_Generator/%s" PATH "createNMUX.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createNMUX.il\n")
		return(-1)
	)

					
	sprintf(FILE "%s/NMUX_Generator/%s" PATH "createNMUXsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createNMUXsch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/MUX_Generator/%s" PATH "createMUXblocksch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createMUXblocksch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/MUX_Generator/%s" PATH "createMUX.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createMUX.il\n")
		return(-1)
	)

	sprintf(FILE "%s/MUX_Generator/%s" PATH "createMUXsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createMUXsch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/REF_Generator/%s" PATH "createREF.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createREF.il\n")
		return(-1)
	)

	sprintf(FILE "%s/REF_Generator/%s" PATH "createREFrowsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createREFrowsch.il\n")
		return(-1)
	)


	sprintf(FILE "%s/REF_Generator/%s" PATH "createREFsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createREFsch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "createRRAManalog.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAManalog.il\n")
		return(-1)
	)

	sprintf(FILE "%s/%s" PATH "createRRAManalogsch.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING createRRAManalogsch.il\n")
		return(-1)
	)

	sprintf(FILE "%s/misc/%s" PATH "calculatePinPosition.il")
	if( !load(FILE) then
		printf("ERROR: FAILED LOADING calculatePinPosition.il\n")
		return(-1)
	)



	
	printf("RRAM COMPILER LOADED SUCCESSFULLY\n")
	return(t)
)	; prog
)	; procedure
