procedure( my_streamIn(	
						FILE			
						;TECHREF
						@optional
						(LIBRARY "DIGITAL_THESIS")
						(MAPFILE "/ibe/local/cadence/kits/tsmc/180n_FORTE/PDK_v02_1.6b_2021/tsmc18/tsmc18.layermap")
						)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
			CMD	
			CID		
			)	
	
	sprintf(CMD "strmin -library %s -strmFile '%s' -logFile 'strmIn.log' -techRefs 'tsmc18' -refLibList reflib.reflib -layerMap %s" LIBRARY FILE MAPFILE)
	printf("SYSTEM: %s\n" CMD)
	CID = ipcBeginProcess(CMD)
	ipcWait(CID)
	sprintf(CMD "cat strmIn.log")
	system(CMD)


	return(t)	
	)	; prog
)	; procedure
