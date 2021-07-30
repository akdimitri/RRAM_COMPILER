;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			23/06/2021
; Description:	This file contains the SKILL search for a digital PIN for RRAM COMPILER
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( 	calculateBusPinPositionDigital( 			; LIST OF ARGUMENTS
									NAME
									BUS
									DB
								)

	prog(	(				; LIST OF LOCAL VARIABLES				
				X
				Y
				z
				x
				b
				point
			)
			
			sprintf(b "\"%s*\"" BUS)
			z = leSearchHierarchy(DB DB~>bBox 1 "label" list(list("text" "==" BUS)))			
			x = setof(x z x~>theLabel==NAME)
			X = car(car(x~>xy))
			Y = car(cdr(car(x~>xy)))
			point = X:Y
			return(point)
	)	; prog
) ; procedure
