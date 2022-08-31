; ==============================================================================
; ==================================> TEMPO <===================================
; ==============================================================================
	
		CBLOCK	0X40
		PDel0
		PDel1
		PDel2

		ENDC
		
; ============================> TIMER1 VALUES LOAD <============================
		
TMR1_LD		MOVLW	0X0B
		MOVWF	TMR1H
		MOVLW	0XDB
		MOVWF	TMR1L
		BSF	T1CON,TMR1ON
		RETURN

; ============> 500 mS <=============

DELAY_500:	MOVLW	.239
		MOVWF	PDel0
PLoop5:		MOVLW	.232
		MOVWF	PDel1
PLoop6:		CLRWDT
DLoop6:		GOTO	DLoop7
DLoop7:		GOTO	DLoop8
DLoop8:		CLRWDT
		DECFSZ	PDel1,1
		GOTO	PLoop6
		DECFSZ	PDel0,1
		GOTO	PLoop5
DLoop9:		GOTO	DLoop10
DLoop10:	GOTO	DLoop11
DLoop11:	GOTO	DLoop12
DLoop12:	CLRWDT
		RETURN


; ============> 100 mS <=============

DELAY_100:	MOVLW	.110
		MOVWF	PDel0
PLoop3:		MOVLW	.181
		MOVWF	PDel1
PLoop4:		CLRWDT
		CLRWDT
		DECFSZ	PDel1,1
		GOTO	PLoop4
		DECFSZ	PDel0,1
		GOTO	PLoop3
DLoop3:		GOTO	DLoop4
DLoop4:		GOTO	DLoop5
DLoop5:		CLRWDT
		RETURN

; ============> 50 mS <==============

DELAY_50:	MOVLW	.55
		MOVWF	PDel0
PLoop13:	MOVLW	.181
		MOVWF	PDel1
PLoop14:	CLRWDT
		CLRWDT
		DECFSZ	PDel1,1
		GOTO	PLoop14
		DECFSZ	PDel0,1
		GOTO	PLoop13
		RETURN

; ============> 20 mS <==============

DELAY_20:	MOVLW	.21
		MOVWF	PDel0
PLoop15:	MOVLW	.237
		MOVWF	PDel1
PLoop16:	CLRWDT
		DECFSZ	PDel1, 1
		GOTO	PLoop16
		DECFSZ	PDel0,1
		GOTO	PLoop15
		CLRWDT
		RETURN

; ============> 5 mS <===============
	
DELAY_5:	MOVLW	.6
		MOVWF	PDel0
PLoop1:		MOVLW	.207
		MOVWF	PDel1
PLoop2:		CLRWDT
		DECFSZ	PDel1,1
		GOTO	PLoop2
		DECFSZ	PDel0,1
		GOTO	PLoop1
Dloop1:		GOTO	DLoop2
DLoop2:		CLRWDT
		RETURN


