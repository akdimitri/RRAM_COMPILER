;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			20/1/2021
; Description:	This file contains the SKILL function runDRC_Calibre. It runs a Calibre DRC check
;-----------------------------------------------------------------------------------------------------------------------------------------
procedure( 	runDRC_Calibre(		; ARGUMENT DECLARATION
				library			; Library Name
				cellname			; Cell Name
			)					; END OF ARGUMENT DELARATION


	prog( 	(					; LOCAL VARIABLE DECLARATION
				cmd 				; cmd variable is used for system function calls. This is a convention made by the author
				TSMC_PDK_PATH 	; Shell variable path to TSMC PDK PATH
				CELL_PATH 		; Unix style path to cell
				RUN_DIRECTORY 	; DRC Run Directory
				RUNSET_FILE 		; Name of runset file used for DRC
				LOG_FILE 		; Log file of DRC
				;CDS_LIB_FILE		; Path to cds.lib
				LIB_DB			; DB object of library
				LIB_PATH			; Library path acquired from cds.lib
				flag 			; used to flag an event
				line 			; used to read a line from a file
				myPort			; Port to a File
				;temp				; a temporary variable for multiple uses
				ERROR_CODE		; Error code number
				cid				; number of process
			)					; END OF LOCAL VARIABLE DECLARATION




		printf("\n\n-------------------\n\nRunning Calibre DRC\n\n-------------------\n\n")
		
		;--------------------------------------------------------------------------
		; STEP 1
		; Create Run Directory for DRC
		; RUN DIRECTORY is created under <path>/<library>/<cell>/.DRC_CALIBRE
		; It is a hidden folder in Cell Folder where various views of cell exist
		;--------------------------------------------------------------------------

		; Read the path of library from cds.lib
		printf("Reading cds.lib\n")
		;sprintf(CDS_LIB_FILE "%s/cds.lib" pwd())		; PATH to cds.lib
		;myPort = infile(CDS_LIB_FILE)					; Open file
		;if( myPort == nil 
		;	then
		;	ERROR_CODE = -1
		;	printf("ERROR: %d --- Failed to open cds.lib %s" ERROR_CODE CDS_LIB_FILE)
		;	return(ERROR_CODE)
		;)
		
		; Read Contents of cds.lib file
		; Check if Library exists
		;flag = 0
		;while( (gets( line myPort)!=nil)
		;	temp = parseString(line)
		;	println(line)
		;	if( ((nth(0 temp) == "DEFINE") && (nth(1 temp) == library))
		;		then
		;		flag = 1
		;		printf("%s\n" buildString(temp))
		;		sprintf(LIB_PATH "%s" nth(2 temp))
		;	)
		;)
		;close(myPort)
		
		; If library path is found continue, Otherwise exit
		;if( flag == 0
		;	then
		;	ERROR_CODE = -2
		;	printf("ERROR: %d --- %s in cds.lib NOT FOUND" ERROR_CODE library)
		;	return(ERROR_CODE)
		;)

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
		sprintf(RUN_DIRECTORY "%s/.DRC_CALIBRE" CELL_PATH)
		sprintf(cmd "mkdir %s" RUN_DIRECTORY)
		printf("SYSTEM: %s\n" cmd)
		;if( !system(cmd) 
		;	then 
		;	ERROR_CODE = -3
		;	printf("ERROR: %d" ERROR_CODE)
		;	return(ERROR_CODE)
		;)
		cid = ipcBeginProcess(cmd)
		ipcWait(cid)
		printf("Creating Run Directory: DONE\n")
		
		;--------------------------------------------------------------------------
		; STEP 2
		; Create RUNSET FILE
		; RUNSET File is created under RUN_DIRECTORY
		; It is needed for DRC CALIBRE
		;--------------------------------------------------------------------------
		; Create GDS needed for runset
		printf("Creating GDS File\n")
		TSMC_PDK_PATH = getShellEnvVar("TSMC_PDK_PATH")
		if(TSMC_PDK_PATH == nil
			then
			ERROR_CODE = -31
			printf("ERROR: %d --- TSMC_PDK_PATH does not exist. Export variable TSMC_PDK_PATH" ERROR_CODE)
			return(ERROR_CODE)
		)
		sprintf(cmd "strmout -library %s -topCell %s -layerMap %s/tsmc18/tsmc18.layermap -techLib tsmc18 -strmFile %s/%s.calibre.db -logFile %s/%s.strmOut.log" library cellname TSMC_PDK_PATH RUN_DIRECTORY cellname RUN_DIRECTORY cellname)
		printf("SYSTEM: %s\n" cmd)
		;if( !system(cmd) 
		;	then 
		;	ERROR_CODE = -4
		;	printf("ERROR: %d" ERROR_CODE)
		;	return(ERROR_CODE)
		;)
		cid = ipcBeginProcess(cmd)
		ipcWait(cid)
		printf("Creating GDS File: DONE\n")
	
		; Create RUNSET file
		printf("Creating runset file\n")
		sprintf(RUNSET_FILE "%s/%s_runset" RUN_DIRECTORY cellname)
		myPort = outfile( RUNSET_FILE "w")
		
		fprintf(myPort "*drcRulesFile: %s/Calibre/drc/calibre.drc\n" pwd())
		fprintf(myPort "*drcRunDir: %s\n" RUN_DIRECTORY)
		fprintf(myPort "*drcLayoutPaths: ./%s.calibre.db\n" cellname)
		fprintf(myPort "*drcLayoutPrimary: %s\n" cellname)
		fprintf(myPort "*drcLayoutLibrary: %s\n" library)
		fprintf(myPort "*drcLayoutView: layout\n")
		fprintf(myPort "*drcResultsFile: %s.drc.results\n" cellname)
		fprintf(myPort "*drcSummaryFile: %s.drc.summary\n" cellname)
		fprintf(myPort "*cmnFDILayoutLibrary: %s\n" library)
		fprintf(myPort "*cmnFDILayoutView: layout\n")
		fprintf(myPort "*cmnFDIDEFLayoutPath: %s.def\n" cellname)
		
		close(myPort)
		printf("Creating runset file: DONE\n")

		;--------------------------------------------------------------------------
		; STEP 3
		; RUN DRC CALIBRE
		;--------------------------------------------------------------------------
		printf("Running CALIBRE DRC\n")
		sprintf(cmd "cd %s && calibre -gui -drc %s_runset -batch > calibre_run.log" RUN_DIRECTORY cellname)		
		printf("SYSTEM: %s\n" cmd)
		;if( !system(cmd) 
		;	then 
		;	ERROR_CODE = -5
		;	printf("ERROR: %d" ERROR_CODE)
		;	return(ERROR_CODE)
		;)
		cid = ipcBeginProcess(cmd)
		ipcWait(cid)
		
		; Print Results
		sprintf(LOG_FILE "%s/calibre_run.log" RUN_DIRECTORY) 
		myPort = infile(LOG_FILE)
		
		if(myPort == nil
			then			
			ERROR_CODE = -6
			printf("ERROR: %d Opening %s for DRC Failed\n" ERROR_CODE LOG_FILE)
			return(ERROR_CODE)			
		)		

		flag = 0
		while( (gets( line myPort)!=nil)
			;println(line)
			if(rexMatchp("--- CALIBRE::DRC-H EXECUTIVE MODULE COMPLETED.*" line)
				then
				flag = 1
			)
			
			if(flag==1
				then
				printf("%s" line)
			)
		)
		close(myPort)
		printf("Running CALIBRE DRC: DONE\n\n")
		return("SUCCESS")

	) ;prog
) ;procedure
