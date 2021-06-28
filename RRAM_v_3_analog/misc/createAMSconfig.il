procedure( createAMSconfig(		; LIST OF ARGUMENTS
								LIBRARY			; LIBRARY
								CELL				; CELL								
								LIBRARY_LIST		; LIBRARY LIST TO BE USED FOR THE CONFIG FILES (ONE STRING SEPERATED BY SPACE)
							)


	prog( 	(	; LIST OF LOCAL VARIABLES
				view
				topview
				viewList
				stopList
				config
			)
	
	;cell="TEST"
	view="config"
	 
	topview="schematic"
	viewList="spectre spice pspice verilog verilogams behavioral functional systemVerilog schematic veriloga vhdl vhdlams wreal"
	stopList="spectre "
	;libList="DIMITRIS_CELL THESIS analogLib basic tsmc18"
	 
	config = hdbOpen(LIBRARY CELL view "w")                      ;; create a new config view
	when(config
		hdbSetTopCellViewName(config LIBRARY CELL topview)      ;; Set Top Cell View Name
		when(stringp(LIBRARY_LIST)
			hdbSetDefaultLibListString(config LIBRARY_LIST)     ;; Set default Library List
		)
		when(stringp(viewList)
			hdbSetDefaultViewListString(config viewList)   ;; Set default Global View List
		)
		when(stringp(stopList)
			hdbSetDefaultStopListString(config stopList)   ;; Set default Global Stop List
		)
	);when config
	
	;spec=list(list("InhConn" "ClockTop" "schematic" "I3"))
	;rule=list('hdbcBindingRule list("InhConn" nil "behavioral") )
	;hdbSetObjBindRule(config spec rule)
	hdbSave(config)
	hdbClose(config)
	return(t)
	;; ----------- Till Here ------------
	)	; prog
)	; procedure
