#include <p16f917.inc>
	
    __CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

    errorlevel -302		; supress "register not in bank0, check page bits" message
        
    org 0x00
    goto	Initialize

    org 0x05
Initialize
; Bank1
    BSF STATUS,RP0
    BCF STATUS,RP1

; Fosc
    MOVLW B'00100000' ; 250kHz
    MOVWF OSCCON

; ADC
    MOVLW B'01010000' ; prescaler = 16
    MOVWF ADCON1 

; IO
    BSF TRISA,2 ;Set RA2 to input
    BSF ANSEL,2 ;Set RA2 to analog

; Bank 0
    BCF STATUS,RP0

; setup ADC
    MOVLW B'10001001' ;Right justify, channel AN2, enabled
    MOVWF ADCON0 

; wait for ADC to be ready
; Bank 1
    BSF STATUS,RP0
    MOVLW B'00000000' ;set PORT B pins to output
    MOVWF TRISB 
    MOVLW B'00000000' ;set PORT D pins to output, for the LED0
    MOVWF TRISD

; Turn off comparators
    MOVLW	0x07
    MOVWF	CMCON0
    
; setup timer
    MOVLW	b'10000111'		;TMR0 Prescaler 1:256
    MOVWF	OPTION_REG		;Delay of sec

; Bank 0
    BCF STATUS,RP0

; start timer
    GOTO ResetTimer
    
ClkLoop
    btfss   INTCON, T0IF	; if CLK flag set?
    goto    ClkLoop		; no, wait until clk overflow
    goto    ResetTimer
    
Main
    BTFSS   PORTD, 7;
    GOTO    MeasurePOT2
    GOTO    MeasurePOT1
ADC
; start ADC conversion
    BSF ADCON0,GO ;
    BTFSC ADCON0,GO ;Is conversion done?
    GOTO $-1 ;No, test again
    
    MOVLW B'11111111';
    XORWF PORTD, f; toggle LED0 via RD 7

; bank 1
    BSF STATUS, RP0;
; read ADC lower 4 bits
    MOVLW B'11111111'
    ANDWF ADRESL, w
; bank 0
    BCF STATUS, RP0;
; put value to port d
    MOVWF PORTB;
    ;RRF PORTB, f;
    ;RRF PORTB, f;
    ;RRF PORTB, f; shift 3 bits to eliminate errors
    ;MOVLW B'00001111' ; debug : test output pins
    
    GOTO ClkLoop

MeasurePOT1 ; via AN2
    MOVLW B'10001001' ;Right justify, channel AN2, enabled
    MOVWF ADCON0 
    GOTO ADC
MeasurePOT2 ; via AN3
    MOVLW B'10001101' ;Right justify, channel AN2, enabled
    MOVWF ADCON0 
    GOTO ADC
; sub routines
ResetTimer
    MOVLW 11; 1s delay
    MOVWF TMR0;
    BCF INTCON, T0IF
    GOTO Main
   
END