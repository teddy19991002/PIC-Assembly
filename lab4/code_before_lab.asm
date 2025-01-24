	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message
    
    ORG 0X00
            GOTO INITIALIZE
    ORG 0X05

INITIALIZE
            ; Bank1
            BSF STATUS,RP0
            BCF STATUS,RP1

            ; Fosc
            MOVLW B'01110000' ; 8MHz
            MOVWF OSCCON
            
            ; turn off comparators
            MOVLW	0x07
            MOVWF	CMCON0

            ; ADC
CFG_ADC    MOVLW B'01010000' ; prescaler = 16, TAD=2us
            MOVWF ADCON1 

            ; IO
            BSF TRISA,2 ;Set RA2 to input
            BSF ANSEL,2 ;Set RA2 to analog

            ; Bank 0
            BCF STATUS,RP0

            ; setup ADC
            MOVLW B'00001001' ;left justify, channel AN2, enabled
            MOVWF ADCON0

            ; After ADC enabled, delay for 2TAD = 4us
            NOP ; delay for 0.5us
            NOP
            NOP
            NOP
            NOP
            NOP
            NOP
            NOP ; 8 * 0.5 = 4us

; get ADC value first, then run pwm.
ADC_GO      BCF     STATUS,RP0; bank0
            ; start ADC conversion
            BSF     ADCON0,GO ;
            BTFSC   ADCON0,GO ;Is conversion done?
            GOTO    $-1 ;No, test again
    
ADC_DONE    ; 1. 0x20 <- ADRESH
            ; bank 0
            BCF     STATUS, RP0;
            ; set indirect address
            MOVLW   0x20;
            MOVWF   FSR;
            ; read ADC high 8 bits
            MOVWF   ADRESH, w
            ; put value to 0x20
            MOVWF   INDF;

            ; 2. 0x21 <- ADRESL
            ; bank 1
            BSF     STATUS, RP0;
            ; set indirect address
            MOVLW   0x21;
            MOVWF   FSR;
            ; read ADC low 8 bits
            MOVWF   ADRESL, w
            ; put value to 0x21
            MOVWF   INDF;
            ; shift right 2 bits
            RRF     INDF, f
            RRF     INDF, f
            ; set 3rd and 2nd bit to 1
            BSF     INDF, 3
            BSF     INDF, 2

CFG_PWM     BSF STATUS,RP0 ;Bank1
            BCF STATUS,RP1

            ;1.  disable CCP2
            BSF TRISC, RD2 ;set RC2 to input

            ;2. set period
            MOVLW 255 ;PR2 0xFF
            MOVWF PR2

            ;3. set ccp2con
            BCF     STATUS,RP0 ;bank0
            MOVLW   b'00111100'; create a mask to filter 2-5 bits.
            ANDWF   0x21, w; read & mask values
            MOVWF   CCP2CON
            
            ;4. set ccpr2l
            MOVF    0x20;CCPR2L
            MOVWF   CCPR2L

            ;5. set timer2
            MOVLW   b'00000100' ;TMR2 ON
            MOVWF   T2CON

            ;6. wait for timer2 to overflow;
            BTFSS   INTCON, T0IF	; if CLK flag set?
            GOTO    $-1		; no, wait until clk overflow

            ; enable ccp2 in a new clock cycle
            BSF     STATUS,RP0 ;Bank 1
            BCF     TRISC, RD2 ;set CCP2 to output

            GOTO ADC_GO;
            END