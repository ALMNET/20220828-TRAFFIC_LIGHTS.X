; ==============================================================================
; =============================> DEVICE DEFINITION <============================
; ==============================================================================
	
	LIST	P=16F877A
	INCLUDE	"P16F877A.INC"
	
; ==============================================================================
; ===============================> CONFIG WORDS <===============================
; ==============================================================================
	
; CONFIG
; __config 0xFF39
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
	
	
	
	RADIX   DEC
	
	
	ORG	0X00
	GOTO	START
	
	INCLUDE	"Tempos.asm"
	INCLUDE	"ADC.asm"
	INCLUDE	"Displays.asm"
	
START	NOP
	BANKSEL	TRISA
	;MOVLW	B'01101010'
	;MOVWF	OSCCON
	MOVLW	B'10000011'
	MOVWF	ADCON1
	MOVLW	B'00111111'
	MOVWF   TRISA	; RA0 as Input
	
	CLRF	TRISC
	CLRF	TRISD
	CLRF	TRISE
	
	BANKSEL PORTA	; Return to Bank0 (Bank where PORTA reg is located)
	
	MOVLW	B'11000001'
	MOVWF	ADCON0

	CLRF    PORTC	; Clear Portc
	CLRF    PORTD	; Clear Portd
	CLRF    PORTE	; Clear Porte
	
	MOVLW	.2
	CALL	DISPLAY
	MOVWF	PORTD
	
	MOVLW	.4
	CALL	ADC_CONVER
	MOVWF	PORTC
	GOTO	$-3
	
;	MOVLW	.255
;	XORWF	PORTC,F
;	CALL	DELAY_500
;	GOTO	$-3
	
	END
	
	

	
	
	