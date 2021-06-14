;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			20/1/2021
; Description:	This file contains the SKILL function runLVS_Calibre. It runs a Calibre LVS check
;-------------------------------------------------------------------------------------------------------------------------------------------- 
procedure( runLVS_Calibre(		; ARGUMENT DECLARATION
				library			; Library cellname
				cellname			; Cell Name
			)					; END OF ARGUMENT DELARATION


	prog(	(					; LOCAL VARIABLE DECLARATION
				CELL_PATH		; Unix style path to cell
				RUN_DIRECTORY	; LVS Run Directory
				SI_FILE			; File si.env to be used from si command
				ERROR_CODE		; Error code number
				LIB_PATH			; Library path acquired from cds.lib
				LIB_DB			; DB object of library
				CDS_DIR			; Path from which virtuoso was invoked
				;spiceFile 
				TSMC_PDK_PATH 	; Shell Variable TSMC Path
				cmd 				; cmd variable is used for system function calls. This is a convention made by the author
				line 			; used to read a line from a file
				myPort			; Port to a File
				inPort			; Port to a File
				RUNSET_FILE		; Name of runset file used for DRC
				LOG_FILE 		; Log file of DRC
				flag 			; used to flag an event
				cid				; number of process
			)					; END OF LOCAL VARIABLE DECLARATION
	
	printf("\n\n-------------------\n\nRunning Calibre LVS\n\n-------------------\n\n")

	;--------------------------------------------------------------------------
	; STEP 1
	; Create Run Directory for LVS
	; RUN DIRECTORY is created under <path>/<library>/<cell>/.LVS_CALIBRE
	; It is a hidden folder in Cell Folder where various views of cell exist
	;--------------------------------------------------------------------------
	printf("Reading cds.lib\n")
	LIB_DB = setof(LIB_DB ddGetLibList() ((LIB_DB~>name)==library))
	if( LIB_DB == nil 
		then
		ERROR_CODE = -1
		printf("ERROR %d: Did not find library.\n" ERROR_CODE)
		return(ERROR_CODE)
	)
	LIB_PATH = car(LIB_DB~>readPath)
	printf("Reading cds.lib: DONE\n")
		
	printf("Creating Run Directory\n")
	sprintf(CELL_PATH "%s/%s" LIB_PATH cellname)
	sprintf(RUN_DIRECTORY "%s/.LVS_CALIBRE" CELL_PATH)
	sprintf(cmd "mkdir %s" RUN_DIRECTORY)
	printf("SYSTEM: %s\n" cmd)
	if( !system(cmd) 
		then 
		ERROR_CODE = -2
		printf("ERROR: %d" ERROR_CODE)
		return(ERROR_CODE)
	)
	printf("Creating Run Directory: DONE\n")


	; Create Spice Netlist - Wrong way
	;simulator("hspiceD")		; set simulator to SPICE
	;design( library cellname "schematic")		; open design 
	;spiceFile = createNetlist( ?recreateAll t ?display nil)	; create spice netlist and store its path
	;printf("Spice Netlist location: %s\n" spiceFile)		; print location
	;simulator("spectre")		; reset simulator
	;sprintf(cmd "cp %s %s/%s/%s/.LVS_CALIBRE/%s.src.net" spiceFile pwd() library cellname cellname)
	;system(cmd)
	
	;--------------------------------------------------------------------------
	; STEP 2
	; Create Spice Netlist for LVS --> auCDL
	; si -batch -cdslib /ibe/users/da220/Cadence/WORK_TSMC180FORTE/cds.lib -command netlist
	;--------------------------------------------------------------------------

	; Create si.env in LVS_CALIBRE folder	
	printf("Creating SPICE netlist\n")
	sprintf(SI_FILE "%s/si.env" RUN_DIRECTORY)
	myPort = outfile( SI_FILE "w")
	if(myPort == nil
		then
		printf("FAIL TO OPEN PORT: %s\n" SI_FILE)
	)
	fprintf(myPort "simLibName = \"%s\"\n" library)
	fprintf(myPort "simCellName = \"%s\"\n" cellname)

	inPort = infile("./SKILL/RRAM_COMPILER/RRAM_v_3_analog/misc/si.env.template")

	while( (gets( line inPort)!=nil)
		fprintf(myPort "%s" line)		
	)
	
	close(inPort)
	close(myPort)

	; run si
	CDS_DIR = pwd()
	sprintf(cmd "cd %s && si -batch -cdslib %s/cds.lib -command netlist" RUN_DIRECTORY CDS_DIR)
	printf("SYSTEM: %s\n" cmd)
	;system(cmd)
	cid = ipcBeginProcess(cmd)
	ipcWait(cid)
	sprintf(cmd "cd %s && mv netlist %s.src.net" RUN_DIRECTORY cellname)
	printf("SYSTEM: %s\n" cmd)
	;system(cmd)	
	cid = ipcBeginProcess(cmd)
	ipcWait(cid)
	printf("Creating SPICE netlist: DONE\n")

	;--------------------------------------------------------------------------
	; STEP 3
	; Create GDS File
	;--------------------------------------------------------------------------
	printf("Creating GDS File\n")
	TSMC_PDK_PATH = getShellEnvVar("TSMC_PDK_PATH")	; read TSMC PDK path. It is needed to locate layermap
	if(TSMC_PDK_PATH == nil
		then
		ERROR_CODE = -31
		printf("ERROR: %d --- TSMC_PDK_PATH does not exist. Export variable TSMC_PDK_PATH" ERROR_CODE)
		return(ERROR_CODE)
	)
	sprintf(cmd "strmout -library %s -topCell %s -layerMap %s/tsmc18/tsmc18.layermap -techLib tsmc18 -strmFile %s/%s.calibre.db -logFile %s/%s.strmOut.log" library cellname TSMC_PDK_PATH RUN_DIRECTORY cellname RUN_DIRECTORY cellname)
	printf("SYSTEM: %s\n" cmd)
	;system(cmd)
	cid = ipcBeginProcess(cmd)
	ipcWait(cid)
	printf("Creating GDS File: DONE\n")
	
	;--------------------------------------------------------------------------
	; STEP 4
	; Create RUNSET FILE
	; RUNSET File is created under RUN_DIRECTORY
	; It is needed for LVS CALIBRE
	;--------------------------------------------------------------------------
	; Create RUNSET file
	printf("Creating Runset File\n")
	sprintf(RUNSET_FILE "%s/%s_runset" RUN_DIRECTORY cellname)
	myPort = outfile( RUNSET_FILE "w")
		
	fprintf(myPort "*lvsRulesFile: %s/Calibre/lvs/calibre.lvs\n" pwd())
	fprintf(myPort "*lvsRunDir: %s\n" RUN_DIRECTORY)
	fprintf(myPort "*lvsLayoutPaths: ./%s.calibre.db\n" cellname)
	fprintf(myPort "*lvsLayoutPrimary: %s\n" cellname)
	fprintf(myPort "*lvsLayoutLibrary: %s\n" library)
	fprintf(myPort "*lvsLayoutView: layout\n")
	;fprintf(myPort "*lvsLayoutGetFromViewer: 1\n")
	fprintf(myPort "*lvsSourcePath: %s.src.net\n" cellname)
	fprintf(myPort "*lvsSourcePrimary: %s\n" cellname)
	fprintf(myPort "*lvsSourceLibrary: %s\n" library)
	fprintf(myPort "*lvsSourceView: schematic\n")
	;fprintf(myPort "*lvsSourceGetFromViewer: 1\n")
	fprintf(myPort "*lvsSpiceFile: %s.sp\n" cellname)
	fprintf(myPort "*lvsERCDatabase: %s.erc.results\n" cellname)
	fprintf(myPort "*lvsERCSummaryFile: %s.erc.summary\n" cellname)
	fprintf(myPort "*lvsReportFile: %s.lvs.report\n" cellname)
	fprintf(myPort "*cmnFDILayoutLibrary: %s\n" library)
	fprintf(myPort "*cmnFDILayoutView: layout\n")
	fprintf(myPort "*cmnFDIDEFLayoutPath: %s.def\n" cellname)
	
	close(myPort)

	;sprintf(cmd "cd %s && calibre -gui -lvs %s_runset -batch > %s.lvs.log" RUN_DIRECTORY cellname cellname)
	;printf("SYSTEM: %s\n" cmd)
	;system(cmd)
	;cid = ipcBeginProcess(cmd)
	;ipcWait(cid)
	printf("Creating Runset File\n: DONE")


	;--------------------------------------------------------------------------
	; STEP 3
	; RUN LVS CALIBRE
	;--------------------------------------------------------------------------
	printf("Running CALIBRE LVS\n")
	sprintf(cmd "cd %s && calibre -gui -lvs %s_runset -batch > calibre_run.log" RUN_DIRECTORY cellname)		
	printf("SYSTEM: %s\n\n\n" cmd)
	;system(cmd)
	cid = ipcBeginProcess(cmd)
	ipcWait(cid)

	; Print Results
	sprintf(LOG_FILE "%s/calibre_run.log" RUN_DIRECTORY) 
	myPort = infile(LOG_FILE)
		
	if(myPort == nil
		then			
		ERROR_CODE = -6
		printf("ERROR: %d Opening %s for LVS Failed\n" ERROR_CODE LOG_FILE)
		return(ERROR_CODE)			
	)		

	flag = 0
	while( (gets( line myPort)!=nil)			
		if(rexMatchp("LVS completed*" line)
			then
			flag = 1
		)
			
		if(flag==1
			then
			printf("%s" line)
		)
	)
	close(myPort)
	printf("Running CALIBRE LVS: DONE\n\n")
	return("SUCCESS")

	)	; prog
)	; procedure
