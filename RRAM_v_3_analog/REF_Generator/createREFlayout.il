procedure(	createREFlayout(					; LIST OF ARGUMENTS								
								B				; B SIZE OF ARRAY (COLS)
								Y 				; Y SIZE OF ARRAY (ROWS)
								LIBRARY			; LIBRARY TO PLACE THE NEW DESIGN
								NAME				; NAME OF THE CELLVIEW
								DB_REF_ROW_CELL		; DB OF REF ROW CELL
								DX				; HORIZONTAL PITCH
								DY				; VERTICAL PITCH
							)
	prog( 	(			; LIST OF LOCAL VARIABLES
			CELLVIEW		; DB OF THE LAYOUT CELL			
			INST_NAME	; TEMPORARY VARIABLE TO HOLD INSTANCE NAME			
			DB_REF_CELL_LAYOUT	; TEMPORARY VARIABLE TO HOLD DB OF REF ROW LAYOUT CELL			
			NET_ID		; TEMPORARY VARIABLE TO HOLD NET ID
			NET_NAME		; TEMPORARY VARIABLE TO HOLD NET NAME
			RECT_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A RECT SHAPE
			PIN_ID		; TEMPORARY VARIABLE TO HOLD THE DB OF A PIN
			LABEL_ID		; TEMPORARY VARIABLE TO HOLD LABEL DB		
			PATH_ID		; TEMPORARY VARIABLE TO HOLD PATH DB							
			)


	printf("Creating Layout for REF.\n")

	CELLVIEW = dbOpenCellViewByType(LIBRARY NAME "layout" "maskLayout" "w")	; Create layout view
	DB_REF_CELL_LAYOUT = dbOpenCellViewByType(DB_REF_ROW_CELL~>libName DB_REF_ROW_CELL~>cellName "layout" "maskLayout" "r")	

	for( i 1 Y
		printf("Placing REF ROW %d\n" i)
		sprintf(INST_NAME "REF_ROW<%d>" i)
		dbCreateInst(CELLVIEW DB_REF_CELL_LAYOUT INST_NAME list(0 (i-1)*DY) "R0")
		
		; PIN SEL<i>
		sprintf(NET_NAME "SEL<%d>" i)
		NET_ID=dbMakeNet(CELLVIEW NET_NAME)
		RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list(2.385:(0.755+(i-1)*DY-0.115) 2.615:(0.755+(i-1)*DY+0.115)))
		dbAddFigToNet(RECT_ID NET_ID)
		PIN_ID=dbCreatePin(NET_ID RECT_ID)
		LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") 2.5:(0.755+(i-1)*DY) NET_NAME "upperCenter" "R0" "roman" 1)	
		PIN_ID~>term~>direction = "input"
		leAttachFig(LABEL_ID PIN_ID~>fig)		
		
	)	;for

	for(j 1 B
		if( modulo(j 2)==1
				then		
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N		
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((-0.115+(j-1)*DX):-0.115 (0.115+(j-1)*DX):0.115))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") ((j-1)*DX):0 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)		
					if( j==1 
						then
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(0.26:0 0.26:-2.53-0.5) 0.94)
							dbAddFigToNet(PATH_ID NET_ID)
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(0.26:(Y-1)*DY 0.26:((Y-1)*DY+2.53)+0.5) 0.94)
							dbAddFigToNet(PATH_ID NET_ID)
						else
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list((j-1)*DX:0 (j-1)*DX:-2.53-0.5) 1.46)
							dbAddFigToNet(PATH_ID NET_ID)
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list((j-1)*DX:(Y-1)*DY (j-1)*DX:((Y-1)*DY+2.53)+0.5) 1.46)
							dbAddFigToNet(PATH_ID NET_ID)
					)
			
					sprintf(NET_NAME "P<%d>" j)	; 	Rows share P			
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)			
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((4.38-0.14+(j-1)*DX):-0.14 (4.38+0.14+(j-1)*DX):0.14))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (4.38+(j-1)*DX):0 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)						
					
				else
					sprintf(NET_NAME "N<%d>" j)	; 	Rows share N
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL1" "drawing") list((-0.115+j*DX):-0.115 (0.115+j*DX):0.115))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL1" "pin") (j*DX):0 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)	
					if( j==B 
						then
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list((j*DX-0.26):0 (j*DX-0.26):-2.53-0.5) 0.94)
							dbAddFigToNet(PATH_ID NET_ID)
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list((j*DX-0.26):(Y-1)*DY (j*DX-0.26):((Y-1)*DY+2.53)+0.5) 0.94)
							dbAddFigToNet(PATH_ID NET_ID)
						else
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(j*DX:0 j*DX:-2.53-0.5) 1.46)
							dbAddFigToNet(PATH_ID NET_ID)
							PATH_ID= dbCreatePath(CELLVIEW list("METAL1" "drawing") list(j*DX:(Y-1)*DY j*DX:((Y-1)*DY+2.53)+0.5) 1.46)
							dbAddFigToNet(PATH_ID NET_ID)
					)
					
					sprintf(NET_NAME "P<%d>" j)
					NET_ID=dbMakeNet(CELLVIEW NET_NAME)
					RECT_ID = dbCreateRect(CELLVIEW list("METAL4" "drawing") list((5.62-0.14+(j-2)*DX):-0.14 (5.62+0.14+(j-2)*DX):0.14))
					dbAddFigToNet(RECT_ID NET_ID)
					PIN_ID=dbCreatePin(NET_ID RECT_ID)
					LABEL_ID = dbCreateLabel(CELLVIEW list("METAL4" "pin") (5.62+(j-2)*DX):0 NET_NAME "upperCenter" "R0" "roman" 1)		
					PIN_ID~>term~>direction = "inputOutput"
					leAttachFig(LABEL_ID PIN_ID~>fig)		
		)	;if	
	)	; for j	

	dbSave(CELLVIEW)		; Save
	) ;prog
)	;procedure
