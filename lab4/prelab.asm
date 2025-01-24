	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message
    
    ORG 0X00
            GOTO INITIALIZE
    ORG 0X05


INITIALIZE  BSF STATUS,RP0 ;Bank1
            BCF STATUS,RP1
            MOVLW B'01110000' ;Set f_osc to 8MHz 
            MOVWF OSCCON

            ;  disable CCP2
            BSF TRISC, RD2 ;set RC2 to input

            ; setting period
            MOVLW 255 ;PR2 0xFF
            MOVWF PR2

            ; set ccp2con
            BCF STATUS,RP0 ;bank0
            MOVLW b'00001100' ;CCP2CON
            MOVWF CCP2CON
            
            ; set ccpr2l
            MOVLW b'11111111' ;CCPR2L
            MOVWF CCPR2L

            ; set timer2
            MOVLW b'00000100' ;TMR2 ON
            MOVWF T2CON

            ; enable ccp2
            BSF STATUS,RP0 ;Bank 1
            BCF TRISC, RD2 ;set CCP2 to output

Loop        NOP
            GOTO Loop
            END
