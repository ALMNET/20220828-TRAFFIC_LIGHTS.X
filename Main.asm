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
	
	
	CBLOCK	0X20
	BACKUP_W
	BACKUP_STA
	TMR1_TICK
	OPER_MODE
	ENDC
	
	
	RADIX   DEC
	
	
	ORG	0X00
	GOTO	SETUP
	
	ORG	0X04
	GOTO	IRQ
	
	INCLUDE	"Tempos.asm"
	INCLUDE	"ADC.asm"
	INCLUDE	"Displays.asm"
	
	;;;;;;;;;;;;;;;;;;;;;;;;; GENERAL SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
SETUP	NOP
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
	
	BSF	PIE1,TMR1IE
	
	BANKSEL PORTA	; Return to Bank0 (Bank where PORTA reg is located)
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;; ADC SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	MOVLW	B'11000001'
	MOVWF	ADCON0
	
	;;;;;;;;;;;;;;;;;;;;;;;;;; PORTS CLEAR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CLRF    PORTC	; Clear Portc
	CLRF    PORTD	; Clear Portd
	CLRF    PORTE	; Clear Porte
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;; TMR1 SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	MOVLW	.2
	MOVWF	TMR1_TICK
	
	MOVLW	B'00110000'
	MOVWF	T1CON
	
	CALL	TMR1_LD
	
	; TMR1 INTERRUPT SETUP
	BSF	INTCON,PEIE
	BSF	INTCON,GIE
	
	;;;;;;;;;;;;;;;;;;;;; VARIABLES INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;
	
	MOVLW	.1
	MOVWF	OPER_MODE
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	GOTO	START
	
	
;	MOVLW	.2
;	CALL	DISPLAY
;	
;	MOVLW	.4
;	CALL	ADC_CONVER
;	MOVWF	PORTC
;	GOTO	$-3
	
;	MOVLW	.255
;	XORWF	PORTC,F
;	CALL	DELAY_500
;	GOTO	$-3
	
	
START
	MOVLW	.4
	CALL	ADC_GET
	CALL	VOLT_TIME_CONV
	
	MOVFW	TIME
	MOVWF	PORTC
	
	
	
	
	
	
	GOTO	START
	
	
	
TMR1_LD	MOVLW	0X0B
	MOVWF	TMR1H
	MOVLW	0XDB
	MOVWF	TMR1L
	BSF	T1CON,TMR1ON
	RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ISR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
IRQ	MOVWF	BACKUP_W	; w and status backup
	MOVFW	STATUS
	MOVWF	BACKUP_STA
	
	
	DECFSZ	TMR1_TICK,F	; Ask if tick = 2
	GOTO	RFI		; If not, return from interrupt
	
	MOVLW	.2		; If afirmative...
	MOVWF	TMR1_TICK	; Tick Reload
	
	MOVLW	.255
	XORWF	PORTE,F
	
	
RFI	BCF	PIR1,TMR1IF
	
	MOVFW	BACKUP_STA	; w and status restore
	MOVWF	STATUS
	MOVFW	BACKUP_W
	RETFIE
	
	
	END
	
	
