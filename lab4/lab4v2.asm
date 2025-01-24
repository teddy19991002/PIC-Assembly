#include <p16f917.inc>

	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

    ORG 0x00
    GOTO Initialize
    ORG 0x05

Initialize
	; Select Bank1
   	BSF	 STATUS,RP0	   
   	BCF	 STATUS,RP1

   	; I/O pins 
    BSF	TRISD,RD2   ; disable RD2 pwm
	BSF TRISA,2   ; Set RA1 to input
	BSF	ANSEL,2   ; Set RA1 to analog	  

   	; Fosc
    MOVLW	B'01110000'	    ; Fosc = 8 MHz
    MOVWF	OSCCON 

	; Set ADC prescaler
   	MOVLW	B'01010000'   ; ADC prescaler = 16            
   	MOVWF	ADCON1        ; TAD = ADC prescaler/Fosc = 16/8MHz = 2us
	
    ; Set PR2 Value for (maximum resolution is 255)
   	MOVLW	D'255'	    
    MOVWF	PR2
	
	; bank 0
    bcf STATUS, RP0;
    clrf CCPR2L ; clean ccpr2l memory

    ; set CCP2CON
    MOVLW   b'00001100';
    MOVWF   CCP2CON;

    ; set T2CON
    BANKSEL T2CON
    MOVLW	B'00000100'	  ;prescler =1:1, enable, postscaler=1:1  
    MOVWF	T2CON

    ; clear flag
    BCF PIR1, TMR2IF;

	; Set ADCON0
   	BANKSEL ADCON0
	MOVLW 	B'00000101'   ; left justify, internal voltage supply, mutiplexer select RA1/AN1,ADC ON
    MOVWF	ADCON0

	; After ADC enabled, delay for 2TAD = 4us
    NOP ; delay for 0.5us
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP ; 8 * 0.5 = 4us
			
    BSF     ADCON0, GO

    ; wait for tmr2 flag
    BTFSS   PIR1, TMR2IF	; if CLK flag set?
    GOTO    $-1		; no, wait until clk overflow

    ; enable ccp2
    BSF STATUS, RP0;
    BSF TRISD, RD2;

Loop
	; ADC
	BANKSEL ADCON0
	BSF 	ADCON0, GO   ; Start conversion
   	BTFSC 	ADCON0, GO   ; Is conversion done?
    GOTO 	$-1	     ; No , test again
	
	; DAC
	BANKSEL ADRESH
	MOVF ADRESH, W
	MOVWF CCPR2L

	BANKSEL ADRESL
    MOVF    ADRESL, W
    ;MOVWF  WORKING_REG
    RRF     WORKING_REG, W
    RRF     WORKING_REG, W
    IORLW	B'00001100' ; add 11xx

	; Set CCP2CON
	BANKSEL CCP2CON
    MOVWF	CCP2CON

	GOTO Loop
	END