; ==============================================================================
; ================================> DISPLAYS <==================================
; ==============================================================================
	
DISPLAY	CALL	TABLE
	MOVWF	PORTD
	RETURN
	
TABLE	ADDWF	PCL,F
	RETLW	B'00000000'	; 0, Display Off
	RETLW	B'00000110'	; 1
	RETLW	B'01011011'	; 2
	RETLW	B'01111001'	; E
	


