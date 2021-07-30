procedure( my_verilogIn(	
						VERILOG_FILE	
						TECHREF
						@optional
						(LIBRARY "DIGITAL_THESIS")
						(PARAM_FILE "./SKILL/RRAM_COMPILER/RRAM_v_3_analog/misc/ihdlParamFile.template")						
						)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
			CMD			
			CID
			OUT_PORT
			IN_PORT
			)	
	; Generate IHDL Param File
	;sprintf(CMD "touch temp_ihdlParam")
	;printf("SYSTEM: %s\n" CMD)
	;CID = ipcBeginProcess(CMD)
	;ipcWait(CID)
	
	sprintf(FILE "./temp_ihdlParam")
	OUT_PORT = outfile( FILE "w")	

	fprintf(OUT_PORT "dest_sch_lib := %s\n" LIBRARY) 
	fprintf(OUT_PORT "ref_lib_list := tsmc18, %s, basic\n" TECHREF) 	
	

	IN_PORT = infile(PARAM_FILE)
	while( (gets( line IN_PORT)!=nil)	
		fprintf(OUT_PORT "%s" line)
	)

	close(IN_PORT)
	close(OUT_PORT)

	sprintf(CMD "ihdl -cdslib cds.lib -param temp_ihdlParam %s" VERILOG_FILE)
	printf("SYSTEM: %s\n" CMD)
	CID = ipcBeginProcess(CMD)
	ipcWait(CID)	


	return(t)	
	)	; prog
)	; procedure
