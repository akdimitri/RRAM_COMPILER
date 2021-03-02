;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			28/1/2021
; Description:	This file contains the SKILL function runLVS_Calibre. It runs a Calibre PEX check
;-------------------------------------------------------------------------------------------------------------------------------------------- 
procedure( runPEX_Calibre(		; ARGUMENT DECLARATION
				library			; Library Name
				cellname			; Cell Name
			)					; END OF ARGUMENT DELARATION
	
	prog( 	(					; LOCAL VARIABLE DECLARATION
				LIB_DB			; DB object of library
				ERROR_CODE		; Error code number
				LIB_PATH			; Library path acquired from cds.lib
				CELL_PATH		; Unix style path to cell
				RUN_DIRECTORY	; LVS Run Directory
				cmd 				; cmd variable is used for system function calls. This is a convention made by the author
				CDS_DIR			; Path from which virtuoso was invoked
				SI_FILE			; File si.env to be used from si command
				myPort			; Port to a File
				inPort			; Port to a File
				cid				; number of process
				TSMC_PDK_PATH 	; Shell Variable TSMC Path
				LOG_FILE 		; Log file of DRC
				flag 			; used to flag an event
				line 			; used to read a line from a file
				RUNSET_FILE		; Name of runset file used for DRC
				NETLIST			; PEX NETLIST
			)					; END OF LOCAL VARIABLE DECLARATION
			

	printf("\n\n-------------------\n\nRunning Calibre PEX\n\n-------------------\n\n")
		
	;--------------------------------------------------------------------------
	; STEP 1
	; Create Run Directory for PEX
	; RUN DIRECTORY is created under <path>/<library>/<cell>/.PEX_CALIBRE
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
	sprintf(RUN_DIRECTORY "%s/.PEX_CALIBRE" CELL_PATH)
	sprintf(cmd "mkdir %s" RUN_DIRECTORY)
	printf("SYSTEM: %s\n" cmd)
	if( !system(cmd) 
		then 
		ERROR_CODE = -2
		printf("ERROR: %d" ERROR_CODE)
		return(ERROR_CODE)
	)
	printf("Creating Run Directory: DONE\n")

	;--------------------------------------------------------------------------
	; STEP 2
	; Create Spice Netlist for LVS --> auCDL
	; si -batch -cdslib /ibe/users/da220/Cadence/WORK_TSMC180FORTE/cds.lib -command netlist
	;--------------------------------------------------------------------------

	; Create si.env in LVS_CALIBRE folder	
	printf("Creating SPICE netlist\n")
	sprintf(SI_FILE "%s/si.env" RUN_DIRECTORY)
	myPort = outfile( SI_FILE "w")
	
	fprintf(myPort "simLibName = \"%s\"\n" library)
	fprintf(myPort "simCellName = \"%s\"\n" cellname)

	inPort = infile("./SKILL/RRAM_COMPILER/RRAM_old/si.env.template")

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
	; It is needed for PEX CALIBRE
	;--------------------------------------------------------------------------
	; Create RUNSET file
	printf("Creating Runset File\n")
	sprintf(RUNSET_FILE "%s/%s_runset" RUN_DIRECTORY cellname)
	myPort = outfile( RUNSET_FILE "w")

	fprintf(myPort "*pexRulesFile: %s/Calibre/rcx/calibre.rcx\n" pwd())
	fprintf(myPort "*pexRunDir: %s\n" RUN_DIRECTORY)
	fprintf(myPort "*pexLayoutPaths: ./%s.calibre.db\n" cellname)
	fprintf(myPort "*pexLayoutPrimary: %s\n" cellname)
	fprintf(myPort "*pexLayoutLibrary: %s\n" library)
	fprintf(myPort "*pexLayoutView: layout\n")
	fprintf(myPort "*pexSourcePath: %s.src.net\n" cellname)
	fprintf(myPort "*pexSourcePrimary: %s\n" cellname)
	fprintf(myPort "*pexSourceLibrary: %s\n" library)
	fprintf(myPort "*pexSourceView: schematic\n")
	fprintf(myPort "*pexPexGroundName: 1\n")
	fprintf(myPort "*pexPexGroundNameValue: gnd!\n")
	fprintf(myPort "*pexIncludeCmdsType: SVRF\n")
	fprintf(myPort "*pexSVRFCmds: {SOURCE CASE YES} {LAYOUT CASE YES} {}\n")
	fprintf(myPort "*pexReportFile: %s.lvs.report\n" cellname)
	fprintf(myPort "*pexPexNetlistFile: %s.pex.netlist\n" cellname)
	fprintf(myPort "*pexPexNetlistFormat: CALIBREVIEW\n")
	fprintf(myPort "*pexPexReportFile: %s.pex.report\n" cellname)
	fprintf(myPort "*pexPexFormatCalibreViewWithNetGeometry: 1\n")
	fprintf(myPort "*pexPexLocation: 1\n")
	fprintf(myPort "*pexPexRlocation: 1\n")
	fprintf(myPort "*pexSVDBnopinloc: 1\n")
	fprintf(myPort "*pexSVDBcci: 1\n")
	fprintf(myPort "*cmnShowOptions: 1\n")
	fprintf(myPort "*cmnUseCBforRVE: 0\n")
	fprintf(myPort "*cmnRunHier: 2\n")
	fprintf(myPort "*cmnSlaveHosts: {use {}} {hostName {}} {cpuCount {}} {a32a64 {}} {rsh {}} {maxMem {}} {workingDir {}} {layerDir {}} {mgcLibPath {}} {launchName {}}\n")
	fprintf(myPort "*cmnLSFSlaveTbl: {use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}\n")
	fprintf(myPort "*cmnGridSlaveTbl: {use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}\n")
	fprintf(myPort "*cmnFDILayoutLibrary: %s\n" library)
	fprintf(myPort "*cmnFDILayoutView: layout\n")
	fprintf(myPort "*cmnFDIDEFLayoutPath: %s.def\n" cellname)

	close(myPort)
	printf("Creating Runset File\n: DONE")

	;--------------------------------------------------------------------------
	; STEP 3
	; RUN LVS CALIBRE
	;--------------------------------------------------------------------------
	printf("Running CALIBRE PEX\n")
	sprintf(cmd "cd %s && calibre -gui -pex %s_runset -batch > calibre_run.log" RUN_DIRECTORY cellname)		
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
		printf("ERROR: %d Opening %s for PEX Failed\n" ERROR_CODE LOG_FILE)
		return(ERROR_CODE)			
	)		

	flag = 0
	while( (gets( line myPort)!=nil)			
		if(rexMatchp("--- CALIBRE xRC::FORMATTER COMPLETED" line)
			then
			flag = 1
		)
			
		if(flag==1
			then
			printf("%s" line)
		)
	)
	close(myPort)


	; Calibre Setup View Interface
	sprintf(NETLIST "%s/%s.pex.netlist" RUN_DIRECTORY cellname)
	mgc_rve_create_cellview(NETLIST)
	printf("Running CALIBRE PEX: DONE\n\n")
	return("SUCCESS")
	

	)	; prog
)	; procedure
