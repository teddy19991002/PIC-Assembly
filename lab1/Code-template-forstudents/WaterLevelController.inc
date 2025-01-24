#include <p16f917.inc>

	__CONFIG    _CP_OFF & _CPD_OFF & _BOD_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF

	errorlevel -302		; supress "register not in bank0, check page bits" message

; Pin Declarations

;--- Student Complete Section below
; I/O: 
;SW2 -> RD4
;SW3 -> RD5

;RD1 -> LED D1
;RD2 -> LED D2
;RD3 -> LED D7 

#define LED1	PORTD, 1
#define LED2	PORTD, 2
#define LED7	PORTD, 3
	
#define SW2	PORTD, 4
#define SW3	PORTD, 5

;The address to store sensor value
#define SensorAddr	0x30; 00=(off off); 01=(off on); 10=(on off); 11=(on on);

;--- Student Complete Section above
; Variable Declarations
	cblock	0x20
		Temp
	endc






