lab2.asm:
;************************************************************************************
;   Filename:      lab2.asm                                          
;   Date:                                                  
;   File Version:  1.00                                                                  
;                                                                      
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          WaterLevelController.inc                                                           
;************************************************************************************
;                                                                     
;    Notes:                                                           
;                                                        
;************************************************************************************
	
#include	<lab2.inc> 			; this file includes variable definitions and pin assignments	
__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

errorlevel -302        ; supress "register not in bank0, check page bits" message
    
    org 0x00
    goto	Initialize

    org 0x05
Initialize
; config IO
    bsf	STATUS, RP0		; switch to bank 1
    bcf     STATUS, RP1
    bcf 	PORT_LED		; pin10 is output

; Set internal oscillator frequency
	movlw	F_OSC
	movwf	OSCCON
; Set TMR0 parameters
	movlw	TMR0_param
	movwf	OPTION_REG		
; Turn off comparators
	movlw	0x07
	movwf	CMCON0
; Turn off Analog 
	clrf	ANSEL

	bcf     STATUS, RP0   ; Bank0
Main
    ; set timer
    movlw   TMR0_init_value     ; set TMR0 init value
    movwf   TMR0
    bcf     INTCON, T0IF        ; clear TMR0 overflow flag;
   

    ; toggle flag
    movlw	b'00000100' ; toggle the led
    xorwf	PORTD, 1; 

Loop
    btfss   INTCON, T0IF	; if CLK flag set?
    goto	Loop		; no, wait until clk overflow
    goto    Main        ; yes, toggle the led
    
    end