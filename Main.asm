; ==============================================================================
; =============================> DEVICE DEFINITION <============================
; ==============================================================================
	
	LIST	P=16F877A
	INCLUDE	"P16F877A.INC"
	
; ==============================================================================
; ===============================> CONFIG WORDS <===============================
; ==============================================================================
	
; CONFIG Fuses for 4 MHz XR, No WDT, No Power on Timer, No Low Voltage Programming
;	 No code read protection and  No code Write protection
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
 

	CBLOCK	0X20
	BACKUP_W	; W backup register for interrupt purposes
	BACKUP_STA	; Status backup register for interrupt purposes
	TMR1_TICK	; 500 ms Tick for TMR1 (2 Ticks mean 1 seg)
	OPER_MODE	; Single, Double or Emergency (Stop)
	TIME1		; Time 1 for single operation
	TIME2		; Time 2 for single operation
	TIME3		; Time 3 for single operation
	TIME4		; Time 4 for single operation
	TIME1_D		; Time 1 for Double Oper (The greater bet TIME1 and TIME3)
	TIME2_D		; Time 2 for Double Oper (The greater bet TIME2 and TIME4)
	TOTAL_TIME	; Result of TIME1 + TIME2 + TIME3 + TIME4
	TIME1_BK	; TIME1 Backup to restore timers when a cycle is completed
	TIME2_BK	; TIME2 Backup
	TIME3_BK	; TIME3 Backup
	TIME4_BK	; TIME4 Backup
	ENDC
	
#DEFINE	OP_SING	1	; Just operation mode definitions
#DEFINE	OP_DOUB	2
#DEFINE	OP_EMER	3
	
	
	
	RADIX   DEC
	
	
	ORG	0X00	; Reset Vector
	GOTO	SETUP
	
	ORG	0X04	; Interrupt Vector
	GOTO	IRQ
	
	INCLUDE	"Tempos.asm"	; General delay file (Library)
	INCLUDE	"ADC.asm"	; ADC routines library
	INCLUDE	"Displays.asm"	; Simple 7 segment table library for 1, 2 and E
	
	;;;;;;;;;;;;;;;;;;;;;;;;; GENERAL SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
SETUP	NOP
	BANKSEL	TRISA
	;MOVLW	B'01101010'
	;MOVWF	OSCCON
	MOVLW	B'10000011'
	MOVWF	ADCON1
	MOVLW	B'00111111'
	MOVWF   TRISA	; RA0 as Input
	
	MOVLW	.1
	MOVWF	PORTB	; RB0 as Input for Stop Button
	MOVWF	PORTE	; RE0 as Input for Operation Mode Switch
	
	CLRF	TRISC	; PORTC as Output
	CLRF	TRISD	; PORTD as Output
					
	BSF	OPTION_REG,7		; Disables Internal Portb Pullups
	
	BSF	OPTION_REG,INTEDG	; Enables RB0 to interrupt on rising
					; edge
;	BCF	OPTION_REG,INTEDG	; Enables RB0 to interrupt on falling
					; edge
					
;	BCF	OPTION_REG,RBPU		; Enables Internal Portb Pullups
	
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
	
	BSF	INTCON,PEIE	; Peripheral Interrupt Enable (for TMR1 Enable)
	
	;;;;;;;;;;;;;; STOP BUTTON AND INTERNAL INTERRUP SETUP ;;;;;;;;;;;;;;
	
	BSF	INTCON,GIE	; General Interrupt Enable
	
	;;;;;;;;;;;;;;;;;;;;; VARIABLES INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;
	
	MOVLW	OP_SING		
	MOVWF	OPER_MODE	; Single mode by default
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	GOTO	ITERATS
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INTERATIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
ITERATS	CLRF	TOTAL_TIME
	
	; Pot1 Time value read
	MOVLW	.0		; Channel 0 selected
	CALL	ADC_GET		; Save ADC Values
	CALL	VOLT_TIME_CONV	; Volt to time conversion
	MOVWF	TIME1		; Store value on TIME1
	MOVWF	TIME1_BK	; Backup for later interrupt purposes
	ADDWF	TOTAL_TIME,F	; Add time read to TOTAL_TIME
	
	; Pot2 Time value read
	MOVLW	.1		; Channel 1 selected
	CALL	ADC_GET
	CALL	VOLT_TIME_CONV
	MOVWF	TIME2		; Store value on TIME1
	MOVWF	TIME2_BK	; Backup for later interrupt purposes
	ADDWF	TOTAL_TIME,F
	
	; Pot3 Time value read
	MOVLW	.2		; Channel 2 selected
	CALL	ADC_GET
	CALL	VOLT_TIME_CONV
	MOVWF	TIME3		; Store value on TIME1
	MOVWF	TIME3_BK	; Backup for later interrupt purposes
	ADDWF	TOTAL_TIME,F
	
	; Pot4 Time value read
	MOVLW	.4		; Channel 4 selected
	CALL	ADC_GET
	CALL	VOLT_TIME_CONV
	MOVWF	TIME4		; Store value on TIME1
	MOVWF	TIME4_BK	; Backup for later interrupt purposes
	ADDWF	TOTAL_TIME,F
	
	
	
	
	; Checks if individual times are less than 1 seg
	MOVLW	.1
	SUBWF	TIME1,W
	BTFSS	STATUS,C
	GOTO	ITERATS		; Less than 0, return and check again
	MOVLW	.1
	SUBWF	TIME2,W
	BTFSS	STATUS,C
	GOTO	ITERATS		; Less than 0, return and check again
	MOVLW	.1
	SUBWF	TIME3,W
	BTFSS	STATUS,C
	GOTO	ITERATS		; Less than 0, return and check again
	MOVLW	.1
	SUBWF	TIME4,W
	BTFSS	STATUS,C
	GOTO	ITERATS		; Less than 0, return and check again
	
	; Checks pass, now lets check the total time if it is in the range
	; of 4 to 10
	
	MOVLW	.10
	SUBWF	TOTAL_TIME,W	; Checks if TOTAL_TIME > 10
	BTFSS	STATUS,C	; Check status looking for the carrier
	GOTO	OP_SEL		; if do, the system goes to operation mode check
	GOTO	ITERATS		; else, we need to restart interations
	

;;;;;;;;;;;;;;;;;;;;;;; OPERATION MODE SWITCH CHECK ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

OP_SEL	BTFSS	PORTE,0
	GOTO	OP_SG		; Switch open, Single Mode selected
	GOTO	OP_DB1
	
OP_SG	MOVLW	.1
	MOVWF	OPER_MODE
	CALL	DISPLAY
	
	; TMR1 Interrupt Enable
	BANKSEL	PIE1		; Switch to bank which PIE1 is located
	BSF	PIE1,TMR1IE	; TMR1 Interrupt Enable
	BANKSEL	PIR1		; Return to bank 0 where PIR1 is located
	
	BSF	INTCON,INTE	; Emergency Stop Interrupt Enable
	GOTO	MAIN_SG		; Just start main single mode, there is nothing 
				; else to do
	
; Checks which one is greater, TIME1 or TIME3
OP_DB1	MOVFW	TIME1
	SUBWF	TIME3,W
	BTFSS	STATUS,C
	GOTO	T1_WINS
	GOTO	T3_WINS
	
T1_WINS	MOVFW	TIME1
	MOVWF	TIME1_BK
	MOVWF	TIME1_D
	GOTO	OP_DB2
	
T3_WINS	MOVFW	TIME3
	MOVWF	TIME1_BK
	MOVWF	TIME1_D
	GOTO	OP_DB2
	
; Checks which one is greater, TIME1 or TIME3
	
OP_DB2	MOVFW	TIME2
	SUBWF	TIME4,W
	BTFSS	STATUS,C
	GOTO	T2_WINS
	GOTO	T4_WINS
	
T2_WINS	MOVFW	TIME2
	MOVWF	TIME2_BK
	MOVWF	TIME2_D
	GOTO	OP_DB3
	
T4_WINS	MOVFW	TIME4
	MOVWF	TIME2_BK
	MOVWF	TIME2_D
	GOTO	OP_DB3
	
OP_DB3	MOVLW	OP_DOUB
	MOVWF	OPER_MODE
	CALL	DISPLAY
	
	; TMR1 Interrupt Enable
	BANKSEL	PIE1		; Switch to bank which PIE1 is located
	BSF	PIE1,TMR1IE	; TMR1 Interrupt Enable
	BANKSEL	PIR1		; Return to bank 0 where PIR1 is located
	
	BSF	INTCON,INTE	; Emergency Stop Interrupt Enable
	GOTO	MAIN_DB		; Starts Double program
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SINGLE MODE PROGRAM ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
MAIN_SG	
	
	
	
	
	
	
	
	
	
	GOTO	MAIN_SG
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DOUBLE MODE PROGRAM ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

MAIN_DB	
	
	
	
	
	
	
	
	
	GOTO	MAIN_DB
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ISR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
IRQ	MOVWF	BACKUP_W	; w and status backup
	MOVFW	STATUS
	MOVWF	BACKUP_STA
	
	BTFSC	PIR1,TMR1IF
	GOTO	TMR_IRQ
	
	BTFSC	INTCON,INTF
	GOTO	STP_IRQ
	GOTO	RFI
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TMR1 INTERRUPT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TMR_IRQ	
	
	MOVLW	.2
	XORWF	PORTE,F		; Just keepalive led toggle
	
	
	; Operation Mode Check
	
	MOVLW	OP_EMER	
	XORWF	OPER_MODE,W
	BTFSC	STATUS,Z
	GOTO	E_MODE
	
	DECFSZ	TMR1_TICK,F	; Ask if tick = 2
	GOTO	RFI		; If not, return from interrupt
	
	MOVLW	.2		; If afirmative...
	MOVWF	TMR1_TICK	; Tick Reload	
	
	MOVLW	OP_SING	
	XORWF	OPER_MODE,W
	BTFSC	STATUS,Z
	GOTO	S_MODE
	
	MOVLW	OP_DOUB
	XORWF	OPER_MODE,W
	BTFSC	STATUS,Z
	GOTO	D_MODE
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SINGLE MODE OPER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
S_MODE	CLRW
	XORWF	TIME1,F
	BTFSS	STATUS,Z
	GOTO	S1_CONT
	CLRW
	XORWF	TIME2,F
	BTFSS	STATUS,Z
	GOTO	S2_CONT
	CLRW
	XORWF	TIME3,F
	BTFSS	STATUS,Z
	GOTO	S3_CONT
	CLRW
	XORWF	TIME4,F
	BTFSS	STATUS,Z
	GOTO	S4_CONT
	
	
	MOVFW	TIME1_BK	; Once a cycle is completed, the values are restored
	MOVWF	TIME1		; and the process restarts again
	
	MOVFW	TIME2_BK
	MOVWF	TIME2
	
	MOVFW	TIME3_BK
	MOVWF	TIME3
	
	MOVFW	TIME4_BK
	MOVWF	TIME4
	
	;GOTO	RFI		; Uncomment this if experiments light 4 delays
	
S1_CONT	DECF	TIME1,F
	MOVLW	B'01010110'
	MOVWF	PORTC
	GOTO	RFI
	
S2_CONT	DECF	TIME2,F
	MOVLW	B'01011001'
	MOVWF	PORTC
	GOTO	RFI
	
S3_CONT	DECF	TIME3,F
	MOVLW	B'01100101'
	MOVWF	PORTC
	GOTO	RFI
	
S4_CONT	DECF	TIME4,F
	MOVLW	B'10010101'
	MOVWF	PORTC
	
	GOTO	RFI
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DOUBLE MODE OPER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
D_MODE	CLRW
	XORWF	TIME1_D,F
	BTFSS	STATUS,Z
	GOTO	D1_CONT
	CLRW
	XORWF	TIME2_D,F
	BTFSS	STATUS,Z
	GOTO	D2_CONT
	
	
	MOVFW	TIME1_BK	; Once a cycle is completed, the values are restored
	MOVWF	TIME1_D		; and the process restarts again
	
	MOVFW	TIME2_BK
	MOVWF	TIME2_D
	
	;GOTO	RFI		; Uncomment this if experiments light 4 delays
	
	
D1_CONT	DECF	TIME1_D,F
	MOVLW	B'01100110'
	MOVWF	PORTC
	GOTO	RFI
	
D2_CONT	DECF	TIME2_D,F
	MOVLW	B'10011001'
	MOVWF	PORTC
	GOTO	RFI
	
;;;;;;;;;;;;;;;;;;;;;;;;;;; EMERGENCY STOP MODE OPER ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
E_MODE	MOVLW	.255
	XORWF	PORTC,F
	GOTO	RFI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RB0 INTERRUPT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
STP_IRQ	MOVLW	OP_EMER
	MOVWF	OPER_MODE
	CALL	DISPLAY
	MOVLW	B'10101010'
	MOVWF	PORTC
	BCF	INTCON,INTF
	BCF	INTCON,RBIE
	GOTO	RFI
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RETURN FROM INTERRUPT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
RFI	BCF	PIR1,TMR1IF
	
	MOVFW	BACKUP_STA	; w and status restore
	MOVWF	STATUS
	MOVFW	BACKUP_W
	RETFIE
	
	
	END
	
	
