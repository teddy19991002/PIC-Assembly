;************************************************************************************
;   Filename:      WaterLevelController.asm                                          
;   Date:          January 25,2008                                          
;   File Version:  1.00                                                                  
;                                                                      
;************************************************************************************
;                                                                     
;    Files required:                                                  
;          WaterLevelController.inc                                                           
;************************************************************************************
;                                                                     
;    Notes:                                                           
;     This project shows the status of a Water Level Controller
;                                                        
;************************************************************************************
	#include	<WaterLevelController.inc> 			; this file includes variable definitions and pin assignments	

;************************************************************************************
  org 0x00
	goto	Initialize

  org 0x05

;************************************************************************************
; Initialize - Initialize comparators, internal oscillator, I/O pins, 
;	analog pins, variables	
;
;************************************************************************************
Initialize
	bsf		STATUS,RP0		; we'll set up the bank 1 Special Function Registers first

; Configure I/O pins for project	

;---- Student Complete Section below
	bcf 	TRISD,1			; RD1 is an output
	bcf 	TRISD,2			; RD2 is an output
	bcf 	TRISD,3			; RD3 is an output
	bsf	TRISD,4			; RD4 is an input
	bsf	TRISD,5			; RD5 is an input

;---- Student Complete Section above


; Set internal oscillator frequency
	movlw	b'01110000'		; 8Mhz
	movwf	OSCCON
; Set TMR0 parameters
	movlw	b'10000110'		; PORTB pull-up disabled, TMR0 Prescaler 1:128
	movwf	OPTION_REG		
; Turn off comparators
	movlw	0x07
	movwf	CMCON0			; turn off comparators
; Turn off Analog 
	clrf	ANSEL

	; Move to bank0
	bcf STATUS, RP0
	; clean memory
	movlw	SensorAddr  ; toggle the sensor
	movwf	FSR	    ; FSR -> SensorAddr 
	movlw	b'00000000';
	movwf	INDF ; clean Sensor address

;************************************************************************************
; Note - When SW2 is pressed, the LED is toggled, and the debounce routine for SW2 is
;        initiated.  Debouncing a switch is necessary to prevent one button press from 
;        being read as more than one button press by the microcontroller.  A 
;        microcontroller can read a button so fast that contact jitter in the switch 
;        may be interpreted as more than one button press.
;
;************************************************************************************

		

Main
;---- Student Complete Section below
	
 	btfss	SW2			; if SW2 pressed
	goto	OnSW2Pressed		; goto SW2 pressed routine
	btfss	SW3			; if SW3 pressed
	goto	OnSW3Pressed		; goto SW3 pressed routine
	
	; Turn On pump if SensorLow = 0
	btfss	SensorAddr,0;
	bsf	LED7;

	; Turn Off pump if SensorHigh = 1
	btfsc	SensorAddr,1;
	bcf	LED7;
	
;---- Student Complete Section above
goto Main

OnSW2Pressed
	movlw	b'00000010'; toggle the RD1, LED1
	xorwf	PORTD, f    ; 
	
	movlw	SensorAddr  ; toggle the sensor
	movwf	FSR	    ; FSR -> SensorAddr 
	movlw	b'00000001'; toggle 1st bit
	xorwf	INDF, f	    ;
	goto DebounceStateSW2	    ; go to Debounce routine

OnSW3Pressed
	movlw	b'00000100'; toggle the RD2, LEd2
	xorwf	PORTD, f    ; 
	
	movlw	SensorAddr   ; FSR -> SensorAddr
	movwf	FSR	    ; 
	movlw	b'00000010'; toggle 2nd bit
	xorwf	INDF, f	    ;
	goto DebounceStateSW3	    ; go to Debounce routine

DebounceStateSW2				; Wait here until SW2 is released
	btfss	SW2
	goto	DebounceStateSW2
	clrf	TMR0			; Once released clear TMR0 and the TMR0 interrupt flag
	bcf		INTCON,T0IF		;  in preparation to time 16ms

DebounceState2SW2				; State2 makes sure than SW2 is unpressed for 16ms before
	btfss	SW2					;  returning to look for the next time SW2 is pressed
	goto	DebounceStateSW2	; If SW2 is pressed again in this state then return to State1
	btfss	INTCON,T0IF 		; Else, continue to count down 16ms
	goto	DebounceState2SW2	; Time = TMR0_max * TMR0 prescaler * (1/(Fosc/4)) = 256*128*0.5E-6 = 16.4ms
	goto	Main

DebounceStateSW3				; Wait here until SW2 is released
	btfss	SW3
	goto	DebounceStateSW3
	clrf	TMR0			; Once released clear TMR0 and the TMR0 interrupt flag
	bcf		INTCON,T0IF		;  in preparation to time 16ms

DebounceState2SW3					; State2 makes sure than SW2 is unpressed for 16ms before
	btfss	SW3					;  returning to look for the next time SW2 is pressed
	goto	DebounceStateSW3	; If SW2 is pressed again in this state then return to State1
	btfss	INTCON,T0IF 		; Else, continue to count down 16ms
	goto	DebounceState2SW3		; Time = TMR0_max * TMR0 prescaler * (1/(Fosc/4)) = 256*128*0.5E-6 = 16.4ms
	goto	Main

	END						; directive 'end of program'
