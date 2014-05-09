
;****************************************************************************************
;*	  F. Beissel
;* Title:		
;* Version:		0.0 (BETA)
;* Last updated:	23.11.04
;* Target:		AT90S2313
;*
;* Support E-mail:	
;* 
;*
;* DESCRIPTION
;*	
;* 	
;*	RS232 functions :
;*
;*	Settings	:	9600 8-N-1
;*
;*	'INCH'			Get one ASCII character from UART
;*	'INCHE'			Get one ASCII character from UART and echo
;*	'OUTCH'			OUT one ASCII to UART
;*	'BYTE'			Get one BYTE from UART ASCII --> ( hex ) --> temp
;*	'OUTH'			Hex-print byte --> ASCII --> OUT UART
;*	'OUTHR'			Hex-print nibble --> ASCII --> OUT UART
;*	'PRINT'			Print asciz-string via Z-pointer
;*
;* COMMANDS	: 
;*	XTAL Range	: 
;*
;***************************************************************************
			  
.include "tn2313def.inc" 
;**** Global Constants ****
.equ	OW_BUS_PORT	= PORTD
.equ	OW_BUS_PIN  = PORTD4

.equ	D0	= 0			; SCL Pin number (port B)
.equ	D1	= 1			; SDA Pin number (port B)
.equ	D_PORT	= PORTB	
.equ	ENA_PORT = PORTD
.equ	ENA_PIN = PORTD2
			
;**** Global Register Variables ****
.def	com_buff= r15			; Command buffer
.def	count		=r22		; Basic_IO 

;***** Global Registers

.equ	AtBCD0	=10		;address of tBCD0
.equ	AtBCD2	=12		;address of tBCD1
.def	tBCD0	=r10	;BCD value digits 1 and 0
.def	tBCD1	=r11	;BCD value digits 3 and 2
.def	tBCD2	=r12	;BCD value digit 4
.def	fbinH	=r5		;binary value Low byte
.def	fbinL	=r4		;binary value High byte
;.def	count	=r22	; ds1820 / Basic_IO 

.def	mc8u	=r18		;multiplicand
.def	mp8u	=r26		;multiplier
.def	m8uL	=r26		;result Low byte
.def	m8uH	=r27		;result High byte
.def	mcnt8u	=r25
		;loop counter
.def	flags		=r16
.def	comun_flags =r17
.def	value		=r18		; ds1820 
;.def	sensor		=r19		; ds1820 
.def	mask		=r19		; ds1820 
.def 	wait		=r20		; ds1820 
.def	t_crc		=r21		; ds1820 
.def	count		=r22		; ds1820 / Basic_IO 
.def	error		=r23		; ds1820 
.def	temp		=r24		; scratch 
.def	tmp			=r25
	        ; 
.def	tock		=r29
;.def	XL	=r26		; already def by xxxxdef.inc file
;.def	XH	=r27		;	
;.def	YL	=r28
;.def	YH	=r29
;.def	ZL	=r30
;.def	ZH	=r31
;**************************
;*	flag register bit def.
;**************************
.equ	tick_f		= 6	;flags
.equ	seco_f		= 5
.equ	new_dat_f	= 0	;flags

.equ	own_add = '2'
.equ	com_stop_con = 0x1B	; ESC = Stop
.equ	com_start_con = 0x3C ; < = Start
;************************************************************************** 
;* 
;*  	PROGRAM START - EXECUTION STARTS HERE 
;* 
;************************************************************************** 
.cseg					;CODE segment
.org 0
		rjmp reset		;Reset handler
		nop
		nop
		nop
		nop
		nop
	;rjmp	tack 	;unused ext. interrupt
.org OVF0addr
		rjmp tick	;	;timer counter overflow (5 ms)
		nop			;unused analogue interrupt
		nop
		nop
		nop
		nop
		nop
		nop
		nop
;
;************************************************************************** 


RESET:	
	ldi	temp,0x00	
	out	UBRRH,temp	
	ldi	temp,0x0C ;9600; 0C	; BAUD RATE = 9600,0x0C - 2MHz; 0x17 - 3,686 MHz  
	out	UBRRL,temp	;	      	  ,0x19 - 4MHz, 0x0C - 19200
	ldi	temp,0x00
	out	UCSRA,temp
	ldi	temp,0x18
	out	UCSRB,temp

	ldi	temp,0x06
	out	UCSRC,temp

	ldi	temp,ramend	; stack -> sram end
	out	spl,temp

	ldi	temp,0x4e;4d		;0x5b
	out	OSCCAL,temp

; Init Timer 0			
	ldi 	temp,0x05		;timer prescalar 0x03=/64;0x04=/256;0x05 =/1024
	out 	TCCR0B,temp
	ldi 	temp,0x00
	out 	TCCR0A,temp
	out 	TCNT0,temp		;(256 - n)*256*0.2441 us
	ldi 	temp,2			;enable timer interrupts
	out 	TIMSK,temp	

; wait before init spi interface	
;	ldi		temp,0x00
;	out		TCNT1L,temp		; clr counter
;	out		TCNT1H,temp		; clr counter
;	ldi		temp,0xFF
;	out		TIFR,temp		;clr timer flags
;wait0:
;	in		temp,TIFR		;for time out
;	sbrs	temp,TOV1
;	rjmp	wait0

;	ldi		temp,0xFF
;	out		TIFR,temp		;clr timer flags
;	ldi 	temp,0x02		;enable timer0 OV interrupt
;	out 	TIMSK,temp		

;*	USI Interface (master)
	sbi		DDRB,PB6	;MISO= Output
	cbi		DDRB,PB5	;MOSI= Input
	sbi		DDRB,PB7	;SCK = Output
	cbi		PORTB,PB7	
	ldi		temp,0xC0	; res flags and counter
	out		USISR,temp

	sbi		(ENA_PORT-1), ENA_PIN
	
	sbi		DDRB,PB4
	sbi		PORTB,PB4
	cbi		(OW_BUS_PORT),OW_BUS_PIN		;
	cbi		(OW_BUS_PORT-1),OW_BUS_PIN		; input	


	SBI	DDRD,DDD6
;test:
;	sbi	PORTD,PORTD6
;	cbi	PORTD,PORTD6
;	rjmp	test
;***************************************************************************
		sbi		ENA_PORT,ENA_PIN		
	rcall 	ds1820_sensorid	; get address
	rcall	ds1820_ausloesen
;		sbi		ENA_PORT,ENA_PIN
		rcall	PRI_AUX
	sei

MAIN_M:	rcall	PRI_AUX
MAIN_M_1:;sbrc	flags,seco_f
		;rcall	ds1820_messen
		;cbr		flags,(1<<seco_f)
		sbis	USR,rxc
		rjmp	MAIN_M_1
		in		temp,UDR
		cpi		temp,'a'
		brlt	IS_UP
		subi	temp,' '	; --> upper
IS_UP:
		cpi		temp,com_stop_con
		breq	COM_STOP

SEL_MEN:	
		mov		tmp,comun_flags		; 
		clc
		rol		tmp					; *2 address =2 byte
		ldi		ZL,low(MEN_TAB*2)		; address of subrutine tab		
		ldi		ZH,high(MEN_TAB*2)		; add position in tab
		add		ZL,tmp					
		clr		tmp
		adc		ZH,tmp
		lpm			;r0,(Z)				; r0 = text address
		push	r0						; save address low byte
		adiw	ZL,1
		lpm								; get high byte
		mov		ZH,r0		
		pop		ZL						; get back low byte
		ijmp	

C_FLAGS_0:								; start ?
		cpi		temp,com_start_con
		brne	MAIN_M
		ldi		comun_flags,0x01
		rjmp	MAIN_M


C_FLAGS_1:								; own address
		ldi		comun_flags,0x02
		cpi		temp,own_add
		brne	MAIN_M
		ldi		comun_flags,0x03
		rcall	OUTCH					; echo own address
		sbi		ENA_PORT,ENA_PIN
C_FLAGS_2:								; not own address
		
		rjmp	MAIN_M


C_FLAGS_3:
		cpi		temp,'A'
		breq	COMAND_1		
		cpi		temp,'B'
		breq	COMAND_2
		cpi		temp,'C'
		breq	COMAND_3		
		cpi		temp,'D'
		breq	COMAND_4
		rjmp	MAIN_M			

COM_STOP:
		clr		comun_flags
		cbi		ENA_PORT,ENA_PIN	;disable driver
		rjmp	MAIN_M

COMAND_1:							; measure temp
;		ldi		comun_flags,0x04
		rcall	OUTCH				; ECHO
		rcall	ds1820_messen
		ldi		comun_flags,0x03
		rjmp	MAIN_M
							
COMAND_2:							; get ds1820 address
;		ldi		comun_flags,0x04
		rcall	OUTCH				; ECHO
		rcall 	ds1820_sensorid
		ldi		comun_flags,0x03
		rjmp	MAIN_M

COMAND_3:							; M read V/C
		rcall	OUTCH				; ECHO
		rcall	READ_SPI_16
		ldi		temp,' '
		rcall	OUTCH
		rcall	READ_SPI_16
		ldi		comun_flags,0x03
		rjmp	MAIN_M		

COMAND_4:							; set voltage
		rcall	OUTCH				; ECHO
		ldi		comun_flags,0x08
		ldi		XL,0x80
		ldi		XH,0x00
		rjmp	MAIN_M				

COMAND_4_S:							; set voltage
		cpi		temp,0x08
		brne	COMAND_4_S_1
		rcall	OUTCH
		rjmp	MAIN_M_1


COMAND_4_S_1:
		rcall	HEX_N
		st		X+,temp
		cpi		XL,0x83
		brne	COMAND_4_S_END
		lds		tmp,0x81
		swap	tmp
		add		temp,tmp

	subi	temp,0x09
	sts		0x81,temp
	lds		temp,0x80
	sbci	temp,0x00
	brcc	COMAND_4_S_2
	ldi		temp,0x00
	sts		0x81,temp
COMAND_4_S_2:
	sts		0x80,temp
	cbi		PORTB,PB4		; CS low
	ori		temp,0xa0
	rcall	SPITransfer
	lds		temp,0x81
	rcall	SPITransfer
	sbi		PORTB,PB4		;CS high

		ldi		comun_flags,0x03
		rjmp	MAIN_M
COMAND_4_S_END:
		rjmp	MAIN_M_1				







MAIN:	rcall	PRI_AUX


MAIN3:	rcall	INCHE			; get character and echo

;	cpi	temp,'T'		; goto Trigger Measurement
;	breq	TRIGGER
;	cpi	temp,'R'		; goto Read Temperature
;	breq	READ_T
	cpi	temp,'M'		; goto Measure 
	breq	MEAS_T
	cpi	temp,'S'		; goto Set Pin No.
	breq	SPItran
	cpi	temp,'G'		; goto Get Address
	breq	GET_ADDR
;	cpi	temp,'A'		; goto Set AddressTemperature
;	breq	SET_ADDR
	cpi	temp,'V'		; 
	breq	SET_VOLTAGE
	cpi	temp,'W'		; 
	breq	READ_V_C
	cpi	temp,'H'		; print command list
	breq	HELP_L
	rcall	PRI_AUX			; Print AUX Text

	rjmp	MAIN			;error ask again	
	
MEAS_T: rcall	ds1820_messen
		rjmp 	MAIN
GET_ADDR:
		rcall 	ds1820_sensorid
		rjmp	MAIN
HELP_L:
	rjmp	HELP_LS	
SPItran:
	rcall	SPItrans
	rjmp	MAIN


SET_VOLTAGE:
	rcall	HEX_E
	sts		0x80,temp
	rcall	BYTE
	subi	temp,0x09
	sts		0x81,temp

	lds		temp,0x80
	sbci	temp,0x00
	brcc	SET_VOLTAGE_1
	ldi		temp,0x00
	sts		0x81,temp
SET_VOLTAGE_1:
	sts		0x80,temp
	cbi		PORTB,PB4		; CS low
;	lds		temp,0x80
	ori		temp,0xa0
	rcall	SPITransfer
	lds		temp,0x81
	rcall	SPITransfer
	sbi		PORTB,PB4		;CS high
	rjmp	MAIN

READ_V_C:
	rcall	READ_SPI_16
;	ldi		temp,10
;	rcall	OUTCH
	ldi		temp,' '
	rcall	OUTCH
	rcall	READ_SPI_16
	rjmp	MAIN

READ_SPI_16:
	cbi		PORTB,PB4		; CS low
	nop
	nop
	ldi		temp,0x00
	rcall	SPITransfer
;	rcall	OUTH
;	ldi		temp,0x00		
;	rcall	SPITransfer
;	rcall	OUTH
;rjmp	READ_SPI_16_ret

	andi	temp,0x0F
	mov		fbinH,temp
;	rcall	OUTH
	ldi		temp,0x00
	rcall	SPITransfer

	mov		fbinL,temp
	lsl		fbinL		; * 2
	rol		fbinH		;
	rcall	bin2BCD16
	mov		temp,tBCD2
;	rcall	OUTH
	mov		temp,tBCD1
	rcall	OUTH
	mov		temp,tBCD0
;	swap	temp
	rcall	OUTH
	ldi temp,'0'
	rcall	OUTCH
	ldi temp,'m'
	rcall	OUTCH
	ldi temp,'V'
	rcall	OUTCH

READ_SPI_16_ret:
	sbi		PORTB,PB4		;CS high
	ret


SPItrans:
	cbi		PORTB,PB4		; CS low
	rcall	PRI_AUX			; Print AUX Text
	ldi		temp,0x9f
	rcall	SPITransfer
	rcall	OUTH
	ldi		temp,0xff
	rcall	SPITransfer
	sbi		PORTB,PB4		;CS high
	rcall	OUTH
	rjmp	MAIN



;***********************************************
;*	SPI
;***********************************************

SPITransfer:
	out 	USIDR,temp
	ldi 	temp,(1<<USIOIF)
	out 	USISR,temp
	ldi 	temp,(1<<USIWM0)|(1<<USICS1)|(1<<USICLK)|(1<<USITC)

SPITransfer_loop:
	nop
	nop
	out 	USICR,temp
	nop
	nop
	sbis	 USISR,USIOIF
	rjmp 	SPITransfer_loop
	in 		temp,USIDR
	ret	
;****************************************************************************
;***** 	Timer0 Overflow Interrupt service routine 				*************
;***** Updates x ms, to provide time reference 					*************
;****************************************************************************

tick:	push	temp
		in		temp,SREG
		push	temp		
			inc 	tock		;add one to 5 ms 'tock' counter
			cpi 	tock,100;100	;is one second up?
			breq 	onesec		;yes, add one to seconds
			rjmp	nosecond
onesec:		;sbrs	flags,set_time_f
			;inc 	second				;add one to seconds
			sbr 	flags,(1<<seco_f) 	;0x20	; new second flag
			clr 	tock				;clear 5 ms counter

nosecond:	ldi 	temp,178;100  ;(4MHz/1024)/(256-178) ~ 20ms
			out 	TCNT0,temp		
		pop		temp
		out		SREG,temp  	;out SREG,status	;restore status register
		pop		temp
		reti			;return to main
;
	
.include "OW_DS1820.asm"
.include "BASIC_IO.asm"
;

MEN_TAB:
.dw	C_FLAGS_0,C_FLAGS_1,C_FLAGS_2,C_FLAGS_3,COMAND_1,COMAND_2,COMAND_3,COMAND_4,COMAND_4_S


;****************************************
;          TEXT STRING
;****************************************
HTEXT:	.db 10,13
	.db "SIPM_CONTROL V0"
	.db 10,00
	.db 00,00	
AUXPMT:	.db 13,10
	.db "* "
	.db  00,00

ERR_TX: .db 10,13
	.db "? "
	.db  00,00
;--------------------------------------------------------------------------
HELP_TX:
	.db 10,13
	.db 10,13
	.db "Comand :"
	.db 10,10,13,13
	.db "'A' set a new DS sensor address "
	.db 10,13
	.db "'G' read one sensor address "
	.db 10,13
	.db "'T' starts the measurement of the actuall Sensor"
	.db 10,13
	.db"'R' reads the last measurement"
	.db 10,13
	.db "'M' measure and read the Temperature of the aktuall sensor"
	.db 10,13
;	.db "'B' DIGITAL I/O  I INIT, W write Data to Outputs, R Read Data "
;	.db 10,13
;	.db "'D' DAC Output  16 bit (channel No. D15 D14  1 1 DAC Data D11 ... D0 )"
;	.db 10,13		
;	.db "'V' ADC Input  Select cannel 3 bit, Return (0 channel No. D14..D12 )"
;	.db "( ADC Data D11..D0 )"
;	.db 10,13
;	.db "'S' Sensirion Sensor, S select Sensor 1/2, R Read Data"
;	.db 10,13
;	.db "'F' Flow sensor Frequency max 255 Hz"
;	.db 10,13
	.db 10,13			
	.db "'H' Print this list "
	.db 10,13
	.db 10,10
	.db "Return: "		
	.db 10,13
	.db 10,13
	.db "'*'  OK ready "
	.db 10,13
	.db "':'  Enter a hex value"
	.db 10,13
	.db "'?x' Error"
	.db 10,13
	.db "Error codes:"
	.db 10,13
	.db "1 no Sensor found "
	.db 10,13
	.db "2 more then one Sensor"
	.db 10,13
	.db "3 bit error "
	.db 10,13
	.db "4 cheksum error "
	.db 00,00
	
 
	


