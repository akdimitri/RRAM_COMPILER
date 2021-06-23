;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			23/06/2021
; Description:	This file contains the SKILL to load SKILL scripts for RRAM COMPILER
;-------------------------------------------------------------------------------------------------------------------------------------------- 

procedure( 	calculatePinPosition( 			; LIST OF ARGUMENTS
									DB_PIN
								)

	prog(	(				; LIST OF LOCAL VARIABLES
				X1			; X of 1st pair
				Y1			; Y of 1st pair
				X2			; X of 2nd pair
				Y2			; Y of 2nd pair
				X
				Y
				point
			)

			X1 = car(car(car(car(DB_PIN~>pins~>fig~>bBox))))
			Y1 = car(cdr(car(car(car(DB_PIN~>pins~>fig~>bBox)))))
			X2 = car(car(cdr(car(car(DB_PIN~>pins~>fig~>bBox)))))
			Y2 = car(cdr(car(cdr(car(car(DB_PIN~>pins~>fig~>bBox))))))

			X = (X1+X2)/2
			Y = (Y1+Y2)/2
			point = X:Y
			return(point)
	)	; prog
) ; procedure
