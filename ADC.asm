; ==============================================================================
; ===================================> ADC <====================================
; ==============================================================================

	
	
	CBLOCK	0X50
	SHIFT_REG
	VOLTAGE_L
	VOLTAGE_H
	MID_RAN_V
	ADC_CONT
	HUNDREDS
	TENS
	UNIT
	TIME
	ENDC
	

; ============================> ADC CONVERSION <============================

ADC_GET:	MOVWF	SHIFT_REG	; Saves w value into SHIFT_REG
		BCF	STATUS,C	; Clear Carry before rotation
		RLF	SHIFT_REG,F	; 1 Time left rotation
		BCF	STATUS,C	; Clear Carry before rotation
		RLF	SHIFT_REG,F	; 2 Times left rotation
		BCF	STATUS,C	; Clear Carry before rotation
		RLF	SHIFT_REG,F	; 3 Times left rotation
		
		BCF	ADCON0,3
		BCF	ADCON0,4
		BCF	ADCON0,5	; Set Channel 0 by default
		
		MOVFW	SHIFT_REG
		IORWF	ADCON0,F	; Set desired channel using w
	
		BCF	PIR1,ADIF
		MOVLW	.7
		MOVWF	ADC_CONT
		DECFSZ  ADC_CONT,F
		GOTO    $-1
		BSF	ADCON0,GO
		BTFSS	PIR1,ADIF
		GOTO	$-1
		BCF	PIR1,ADIF
		
		BANKSEL	ADRESL
		MOVFW	ADRESL
		BANKSEL	ADRESH
		MOVWF	VOLTAGE_L
		
		MOVFW	ADRESH
		MOVWF	VOLTAGE_H
		RETURN
		

VOLT_TIME_CONV:	CLRF	MID_RAN_V
		CLRF	TIME
		
		MOVLW	.255
		SUBWF	VOLTAGE_L,W
		BTFSC	STATUS,Z
		INCF	TIME,F
		
		
		MOVLW	.125
		SUBWF	VOLTAGE_L,W
		BTFSC	STATUS,C
		INCF	TIME,F
		
FIXING_VOLT:	BCF	STATUS,C
		RLF	VOLTAGE_H,W ; Multiply by 2
		ADDWF	TIME,F	; Adds medium range voltage if do
		
		MOVFW	TIME
		RETURN
		
		
		
		

	
		
		