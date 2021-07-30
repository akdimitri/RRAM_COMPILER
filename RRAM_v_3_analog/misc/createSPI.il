procedure( createSPI(		; ARGUMENT DECLARATION
				library			; Library cellname
				cellname			; Cell Name
			)	
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
			)	
	; Create si.env in LVS_CALIBRE folder	
	printf("Creating SPICE netlist\n")
	sprintf(SI_FILE "%s/DIGITAL_LVS/si.env" RUN_DIRECTORY)
	myPort = outfile( SI_FILE "w")
	if(myPort == nil
		then
		printf("FAIL TO OPEN PORT: %s\n" SI_FILE)
	)
	fprintf(myPort "simLibName = \"%s\"\n" library)
	fprintf(myPort "simCellName = \"%s\"\n" cellname)

	inPort = infile("./SKILL/RRAM_COMPILER/RRAM_v_3_analog/misc/si.env.mixed_template")

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
	)
)
