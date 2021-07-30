;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			23/06/2021
; Description:	This file contains the SKILL search for a digital PIN for RRAM COMPILER
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( 	calculatePinPositionDigital( 			; LIST OF ARGUMENTS
									NAME
									DB
								)

	prog(	(				; LIST OF LOCAL VARIABLES				
				X
				Y
				z
				TERM
				point
			)
	
			z = leSearchHierarchy(DB DB~>bBox 1 "label" list(list("text" "==" NAME)))
			z = setof(TERM z TERM~>theLabel==NAME)
			X = car(car(z~>xy))
			Y = car(cdr(car(z~>xy)))
			point = X:Y
			return(point)
	)	; prog
) ; procedure
