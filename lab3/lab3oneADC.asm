#include <p16f917.inc>                                                              
;************************************************************************************                    
;                                                                                                                               
;     Prelab of lab3
;
;	 Group number: 10
;    Name: Kun Cheng
;    Student ID: 300084721
;
;    A = 10 modulo 8 = 2 ==> Analog channel AN2
;    B =  (10+1) modulo 8 = 3  ==> Analog channel AN3
;
;************************************************************************************
	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message
    
    ORG 0X00
            GOTO INITIALIZE
    ORG 0X05
INITIALIZE  BSF STATUS,RP0 ;Bank1
            BCF STATUS,RP1
            MOVLW B'01110000' ;Set f_osc to 8MHz 
            MOVWF OSCCON
            MOVLW B'01010000' ;ADC prescaler=16, T_AD = Tosc x 16 = 2us > 1.6us
            MOVWF ADCON1

            BSF TRISA,2 ;set RA2 to input, POT1
            BSF ANSEL,2 ;set RA2 to analog

            BCF STATUS,RP0 ;bank0
            MOVLW B'10001001' ;right justify, channel select 2, enabled
            MOVWF ADCON0

            ;delay of 2*T_AD=4us
            NOP ; one NOP causes 1/8MHz x 4 = 0.5 us delay
            NOP 
            ; repeat 8 NOPs here to create 4us delay
	
Loop        BSF ADCON0, GO ;start conversion
            BTFSC ADCON0, GO ;conversion done?
            GOTO $-1 ;test again if not done

            ;The upper 2 bits are in ADRESH
            ;The lower 8 bits are in ADRESL

            GOTO Loop
            END
