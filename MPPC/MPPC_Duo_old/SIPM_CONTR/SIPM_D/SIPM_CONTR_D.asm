
;****************************************************************************************
;*	  F. Beissel
;* Title:	SIPM CONTROLLER	
;* Version:		0.0 (BETA)
;* Last updated:	30.11.09
;* Target:		ATmega48
;*
;* Support E-mail:	
;* 
;*
;* DESCRIPTION
;*	
;* 	
;*	RS232 functions :
;*
;*	Settings	:	19200 8-N-1
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
			  
;.include "m48def.inc"
.include "m88PAdef.inc"
;**** Global Constants ****
;*
;*	0x3e8 = 20V
;*  0x5dc = 30V
;*  0x9c4 = 50V
;*  0xbb8 = 60V
;*  0xDAC = 70V
;* calibration data
;*MODULE NO.: 28 85 49 48 02 00 00 B6
;.equ	v_gain_cal	= 0x7fc8			
;.equ	v_off_cal	= 0x09
;.equ	tr_gain_cal	=
;.equ	tr_off_cal	=
;*MODULE NO.: 28 C6 25 48 02 00 00 AA
.equ	v_gain_cal	= 0x7f32			
.equ	v_off_cal	= 0x12
;.equ	tr_gain_cal	=
;.equ	tr_off_cal	=
;*MODULE NO.: 28 29 E0 FC 01 00 00 2C

;***************************************************************************
;one wire port
.equ	OW_BUS_PORT	= PORTC
.equ	OW_BUS_PIN  = PORTC0
;.equ	D0	= 0			; SCL Pin number (port B)
;.equ	D1	= 1			; SDA Pin number (port B)
;.equ	D_PORT	= PORTB	
;RS485 driver enable
.equ	ENA_PORT = PORTD
.equ	ENA_PIN = PORTD4
.equ	SEL_LED = PORTD5

			
;**** Global Register Variables ****

;.def			= r0
;.def			= r1
;.def			= r2
.def	own_add	= r3
;.def			= r4
;.def			= r5
;.def			= r6
.def	samp_co		= r7
.def	adc_hres	= r8
.def	adc_lres	= r9
.equ	AtBCD0	=10		;address of tBCD0
.equ	AtBCD2	=12		;address of tBCD1
.def	tBCD0	=r10	;BCD value digits 1 and 0
.def	tBCD1	=r11	;BCD value digits 3 and 2
.def	tBCD2	=r12	;BCD value digit 4
.def	fbinH	=r5		;binary value Low byte
.def	fbinL	=r4		;binary value High byte

;.def			= r13	
;.def			= r14		
;.def			= r15		;
.def	HEX_N_NO	= r16
.def	tmp		= r17
.def	tock	= r18
.def	wait	= r19
.def 	count	= r20		
;.def			= r21		
;.def			= r22		 
.def	temp		= r23		; scratch 
.def	flags		= r24
.def	comun_flags			= r25		; scratch 


.def	AH = r23
.def	AL = r22
.def	BH = r21
.def	BL = r20
.def 	CH = r19
.def	CMH= r18
.def	CML= r17
.def	CL = r16
;
;.def	XL	= r26		; already def by xxxxdef.inc file
;.def	XH	= r27		        ; 
;.def	YL	= r28
;.def	YH	= r29
;.def	ZL	= r30
;.def	ZH	= r31
;
;**************************
;*	flag register bit def.
;**************************
.equ	tick_f		= 7	;flags
.equ	seco_f		= 6
.equ	echo_f 		= 5
.equ	call_f		= 4
.equ	first_f		= 3
.equ	ds_err_f 	= 2
.equ	hsec_f		= 1
;.equ		= 0

.equ	com_stop_con = '>';0x1B	 = Stop
.equ	com_start_con = 0x3C ; < = Start

;******************************************
;*	dseg
;******************************************


;****************************************
.equ	own_add_ram = 0x100
.equ	V_coif_ad	= 0x101
.equ	v_off_aH   	= 0x102
.equ	v_off_aL   	= 0x103
.equ	v_gain_a_H	= 0x104
.equ	v_gain_a_L	= 0x105
.equ	v_off_bH   	= 0x106
.equ	v_off_bL   	= 0x107
.equ	v_gain_b_H	= 0x108
.equ	v_gain_b_L	= 0x109
.equ	Tho			= 0x10A
.equ	ThgH		= 0x10B
.equ.	THgL		= 0x10C
.equ	V20a_L		= 0x10D
.equ	V20a_H  	= 0x10E
.equ	V20b_L		= 0x10F
.equ	V20b_H  	= 0x110

.equ	sens_a_no	= 0x111
.equ	sens_b_no	= 0x112
.equ	scratch_RAM=0x113 ;.....0x11A
.equ	received_add = 0x11F
.equ	V_com_fact_H = 0x120
.equ	V_com_fact_L = 0x121
.equ	V_compaH	= 0x122
.equ	V_compaL 	= 0x123
.equ	V_compbH	= 0x124
.equ	V_compbL 	= 0x125
.equ	V_corrb_H 	= 0x126
.equ	V_corrb_L 	= 0x127
.equ	V_corra_H 	= 0x128
.equ	V_corra_L 	= 0x129




;***********************************************
.equ	ad_res_l0 =0x130
.equ	ad_res_h0 =0x131
.equ	ad_res_l1 =0x132
.equ	ad_res_h1 =0x133
.equ	ad_res_l2 =0x134
.equ	ad_res_h2 =0x135
.equ	ad_res_l3 =0x136
.equ	ad_res_h3 =0x137
.equ	ad_res_l4 =0x138
.equ	ad_res_h4 =0x139
.equ	ad_res_l5 =0x13a
.equ	ad_res_h5 =0x13b
.equ	ad_res_l6 =0x13c
.equ	ad_res_h6 =0x13d
.equ	ad_res_l7 =0x13e
.equ	ad_res_h7 =0x13f
;

;.equ	top_themp_L =0x140
;.equ	top_themp_H =0x141
;.equ	bot_themp_L =0x142
;.equ	bot_themp_H =0x143
.equ	tem_l0 =0x140
.equ	tem_h0 =0x141
.equ	tem_l1 =0x142
.equ	tem_h1 =0x143
.equ	tem_l2 =0x144
.equ	tem_h2 =0x145
.equ	tem_l3 =0x146
.equ	tem_h3 =0x147
.equ	tem_l4 =0x148
.equ	tem_h4 =0x149
.equ	tem_l5 =0x14a
.equ	tem_h5 =0x14b
.equ	tem_l6 =0x14c
.equ	tem_h6 =0x14d
.equ	tem_l7 =0x14e
.equ	tem_h7 =0x14f

;###################################################
;
#define Module
;
;###################################################

.eseg
#ifdef Module1
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x01,0x03,0x00,0x01,0xFA,0x00,0x00,0x00,0xFB,0x0F,0x38,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sea1,Sea2,Sea3,Sea4,seb1,Seb2,Seb3,Seb4
.db 0xC6,0x0D,0xC7,0x0D,0x06,0x03,'1','2','6','1','1','2','6','8'

#elif Module2
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x02,0x00,0xff,0xff,0xFA,0xD8,0xff,0xfe,0xFA,0x80,0x70,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'
#elif Module3
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x03,0x00,0x00,0x00,0xFA,0x90,0xFF,0xFD,0xFA,0x40,0x82,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif Module4
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x04,0x03,0xff,0xff,0xFA,0xB0,0x00,0x00,0xFA,0xB0,0x20,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xBB,0x0D,0xC4,0x0D,0x10,0x07,'1','2','6','3','1','2','6','9'
#elif Module5
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x05,0x00,0x00,0x03,0xFA,0xE8,0xff,0xff,0xFA,0x95,0x2B,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif Module6
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x06,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif Module7
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x07,0x00,0x00,0x02,0xF9,0xC0,0x00,0x03,0xFA,0x30,0x4D,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'







#elif Module8
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x08,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif Module9
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x09,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif ModuleA
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x0A,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif ModuleB
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x0B,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif ModuleC
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x0C,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif ModuleD
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x0D,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif ModuleE
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x0E,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x57,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'

#elif ModuleF ; 4 channel auger
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x0F,0x00,0x00,0x00,0xF9,0xD8,0x00,0x01,0xFB,0xA0,0x92,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sera1,Sera2,Sera3,Sera4,serb1,Serb2,Serb3,Serb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'
#else
;Module0
;  ow_ad,Vcoi,VaoH,VaoL VagH,VagL,VboH,VboL,VbgH,VbgL,Tho,ThgH,ZhgL
.db 0x01,0x00,0x00,0x01,0xFA,0x00,0x00,0x00,0xFB,0x13,0x3b,0x00,0x00
;   VaL, VaH, VbL, VbH, Sano,Sbno,Sea1,Sea2,Sea3,Sea4,seb1,Seb2,Seb3,Seb4
.db 0xAC,0x0D,0xAC,0x0D,0x01,0x02,'0','0','0','0','0','0','0','0'
#endif

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
		
.org UTXCaddr		; USART Tx Complete
		rjmp	TX_COMPLETE
		nop
;
;************************************************************************** 


RESET:	

	ldi	temp,low(ramend)	; stack -> sram end
	out	spl,temp
	ldi	temp,high(ramend)	; stack -> sram end
	out	sph,temp


	ldi		temp,0x00	
	sts		UBRR0H,temp
	ldi		temp,0x19;02 ;9600; 0C	; BAUD RATE = 9600,0x0C - 2MHz; 0x17 - 3,686 MHz  
	sts		UBRR0L,temp	;	      	  ,0x19 - 4MHz, 0x0C - 19200
	ldi		temp,0x00
	sts		UCSR0A,temp
	ldi		temp,0x58		; 0x18 Txena,Rxena; 0x58 Txena, TxIena, Rxena
	sts		UCSR0B,temp
	ldi		temp,0x06
	sts		UCSR0C,temp

	cbi		ENA_PORT,ENA_PIN		;RS485 driver disable
	sbi		(ENA_PORT-1),ENA_PIN	;output RS485 driver enable Pin
	sbi		ENA_PORT,SEL_LED		;output RS485 Select LED
	sbi		(ENA_PORT-1),SEL_LED	;output RS485 Select LED
;***********************
;* ADC INIT
	ldi		temp,0xc0		; internal REF, right adjust
	sts		ADMUX,temp
	ldi		temp,0x07
	sts		DIDR0,temp		; disable digital input	
	ldi		temp,0xd6
	sts		ADCSRA,temp		; start ADC

; Init Timer 0			
	ldi 	temp,0x05		;timer prescalar 0x03=/64;0x04=/256;0x05 =/1024
	out 	TCCR0B,temp
	ldi 	temp,0x00
	out 	TCCR0A,temp
	out 	TCNT0,temp		;(256 - n)*256*0.2441 us
	ldi 	temp,1			;enable timer interrupts
	sts 	TIMSK0,temp	


;* read EEPROM
		ldi		XL,0x00		; EEPROM Addresss
		ldi		XH,0x00		; EEPROM Addresss
		ldi		ZL,0x00		; RAM Address
		ldi		ZH,0x01
		ldi		tmp,0x12	; Byts #
EEPROM_read:				; Wait for completion of previous write

	sbic 	EECR,EEPE
	rjmp 	EEPROM_read
						; Set up address (r18:r17) in Address Register
	out 	EEARH,XH
	out 	EEARL,XL						; Start eeprom read by writing EERE
	sbi 	EECR,EERE						; Read data from Data Register
	in 		temp,EEDR
	adiw	XL,0x01
	st		Z+,temp
	dec		tmp
	brne	EEPROM_read
Init_RAM:
	ldi		temp,0x00
	ldi		ZL,0x10		; RAM Address
	ldi		ZH,0x01
;Init_RAM_1:
;	st		Z+,temp
;	cpi		ZL,0x60
;	brne	Init_RAM_1

;*	SPI Interface (master)
	sbi		PORTB,PB2
	sbi		DDRB,PB2	;ENA* = Output
	cbi		DDRB,PB4	;MISO= input
	sbi		DDRB,PB3	;MOSI= output
	sbi		DDRB,PB5	;SCK = Output
	ldi		temp,0x55	; SPI Master ena, clk/16
	out		SPCR,temp
;*
;***************************************************************************
	clr		comun_flags
	ldi		flags,(1<<first_f)
	clr		samp_co	
	clr		adc_hres
	clr		adc_lres
	ldi		temp,0x01
	lds		own_add,own_add_ram

;	ldi		temp,0x39;0x9a
;	sts		v_gain_b_L,temp
;	ldi		temp,0xFB;0x7d
;	sts		v_gain_b_H,temp
;	ldi		temp,0x39;0x9a
;	sts		v_gain_a_L,temp
;	ldi		temp,0xFB;0x7d
;	sts		v_gain_a_H,temp
	sei
	rjmp	MAIN_M_1
;***********************************************************************************

MAIN_M:	ldi		temp,10
		rcall	OUTCH
		ldi		temp,13
		rcall	OUTCH
		ldi		temp,'*'
;		sbrc	flags,ds_err_f
;		ldi		temp,'?'	
		rcall	OUTCH

MAIN_M_1:
		sbrc	flags,hsec_f
		rcall	ADC_INPUT
		sbrc	flags,seco_f

		rcall	DAC_UPDATE
		lds		temp,UCSR0A
		sbrs	temp,RXC0
		rjmp	MAIN_M_1
		lds		temp,UDR0
		cpi		temp,'a'
		brlt	IS_UP
		subi	temp,' '	; --> upper
IS_UP:
		cpi		temp,com_stop_con
		breq	COM_STOP

SEL_MEN:	
		mov		tmp,comun_flags	
		ldi		ZL,low(MEN_TAB*2)		; address of subrutine tab		
		ldi		ZH,high(MEN_TAB*2)		; add position in tab
SEL_MEN1:
		lsl		tmp						; *2 address =2 byte
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

COM_STOP:
		clr		comun_flags
		cbi		ENA_PORT,ENA_PIN	;disable driver
		sbi		ENA_PORT,SEL_LED	; RS485 Select LED off
NO_COMA:
		rjmp	MAIN_M_1	

;********************************************
;*   own address
;********************************************
C_FLAGS_0:								; start ?
		cpi		temp,com_start_con
		brne	C_FLAGS_01
		ldi		comun_flags,0x01		; HEX_IN
		ldi		XL,low(received_add)
		ldi		XH,high(received_add)
		ldi		HEX_N_NO,0x02			; 2 NIBBLE
		clr		count
		ldi		YL,low(scratch_RAM)
		ldi		YH,high(scratch_RAM)
		cbr		flags,(1<<echo_f)
		rjmp	MAIN_M_1				

C_FLAGS_1:
		rcall	HEX_IN
		brcs	C_FLAGS_1_RET
		rjmp	MAIN_M_1
C_FLAGS_1_RET:
		lds		temp,received_add
		cp		temp,own_add
		brne	C_FLAGS_2
		ldi		comun_flags,0x03
		rcall	OUTH				; echo own address
	cbi		ENA_PORT,SEL_LED		; RS485 Select LED on
		rjmp	MAIN_M

C_FLAGS_2:
		ldi		comun_flags,0x02	; not own address
C_FLAGS_01:
		rjmp	MAIN_M_1
;**********************************************

C_FLAGS_3:
	
	sbrc	flags,first_f
	rcall	SET_CALL_MODE


		mov		tmp,temp
		cpi		temp,'A'
		brlt	IS_scaled
		subi	tmp,' '
IS_scaled:
		ldi		ZL,low(MEN_1_TAB*2)		; address of subrutine tab		
		ldi		ZH,high(MEN_1_TAB*2)		; add position in tab
		rjmp	SEL_MEN1


;*************************************************		
		sbrs	flags,call_f
		rjmp	MAIN_M

		cpi		temp,'Y'
		breq	CALL_OFFS_00
		cpi		temp,'X'
		breq	CALL_GAIN_00				
		rjmp	MAIN_M		


SET_CALL_MODE:
		cpi		temp,'Z'
		breq	SET_CALL_MODE_1
		cbr		flags,(1<<first_f)
		ret

SET_CALL_MODE_1:
		sbr		flags,(1<<call_f)
		cbr		flags,(1<<first_f)
		ret
;***************************************************
COMAND_4:
COMAND_A:
COMAND_B:
COMAND_C:
COMAND_D:
COMAND_E:
COMAND_F:
CALL_GAIN_00:
CALL_OFFS_00:

	rjmp	MAIN_M
HELP_L:
		rcall	HELP
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


;************************************************************
;* set Voltage
;************************************************************
; set voltage a
GET_V20A:							
		rcall	OUTCH						; ECHO
		ldi		comun_flags,0x04		; HEX_IN
		ldi		XL,low(V20a_L)
		ldi		XH,high(V20a_L)
;		ldi		HEX_N_NO,0x04			; 4 NIBBLE
		ldi		HEX_N_NO,0x03			; 3 NIBBLE
		clr		count
		ldi		YL,low(scratch_RAM)
		ldi		YH,high(scratch_RAM)
		sbr		flags,(1<<echo_f)

		rjmp	MAIN_M				

; set voltage b
GET_V20B:							
		rcall	OUTCH						; ECHO
		ldi		comun_flags,0x04		; HEX_IN
		ldi		XL,low(V20b_L)
		ldi		XH,high(V20b_L)
		ldi		HEX_N_NO,0x03			; 3 NIBBLE
		clr		count
		ldi		YL,low(scratch_RAM)
		ldi		YH,high(scratch_RAM)
		sbr		flags,(1<<echo_f)
		rjmp	MAIN_M				

GET_HEX:
		rcall	HEX_IN
		brcs	GET_HEX_RET
		rjmp	MAIN_M_1
GET_HEX_RET:
		rjmp	MAIN_M

;**************************************************
;*
;**************************************************
GET_VT_COIF:
		rcall	OUTCH						; ECHO
		ldi		comun_flags,0x04		; HEX_IN
		ldi		XL,low(V_coif_ad)
		ldi		XH,high(V_coif_ad)
		ldi		HEX_N_NO,0x01			; 3 NIBBLE
		clr		count
		ldi		YL,low(scratch_RAM)
		ldi		YH,high(scratch_RAM)
		sbr		flags,(1<<echo_f)
		rjmp	MAIN_M				


;GET_VT_COIF:	; set V compensated factor
		rcall	OUTCH						; ECHO
		ldi		comun_flags,0x05
		rjmp	MAIN_M_1

;GET_VT_HEX:
		rcall	HEX_N
		sts		V_coif_ad,temp
		ldi		comun_flags,0x03
		rjmp	MAIN_M

;****************************************************
;* READ BACK
;****************************************************
READ_Va:	; send compensated voltage
		rcall	OUTCH						; ECHO
		lds		temp,V_compaH	;V_compH
;		rcall	OUTH
		rcall	OUTHR	;	R
		lds		temp,V_compaL	;V_compL
		rcall	OUTH
		ldi		comun_flags,0x03
		rjmp	MAIN_M

READ_Vb:	; send compensated voltage
		rcall	OUTCH						; ECHO
		lds		temp,V_compbH;V20b_H	;V20b_L
		rcall	OUTHR		
		lds		temp,V_compbL;V20b_L	;V_compL
		rcall	OUTH
		ldi		comun_flags,0x03
		rjmp	MAIN_M
;
;
READ_VT_COIF:	; read V compensated factor
		rcall	OUTCH						; ECHO
		lds		temp,V_coif_ad
		rcall	OUTHR
		rjmp	MAIN_M
;****************************************************+
READ_SENSOR_DATA:
		rcall	OUTCH						; ECHO
;*MODULE
		ldi	ZL,low(MODUL_TX*2)
		ldi	ZH,high(MODUL_TX*2)
		clr	tmp
		rcall	PRINT
		ldi		ZL,0x00		; EEPROM Addresss L
		ldi		ZH,0x00		; EEPROM Addresss H
		rcall	read_EEPROM
		rcall	OUTH
;		sbiw	ZL,0x01
;		rcall	read_EEPROM
;		rcall	OUTH

;*SenmsorA
		ldi	ZL,low(SENSORA_TX*2)
		ldi	ZH,high(SENSORA_TX*2)
		clr	tmp
		rcall	PRINT

;* read EEPROM
		ldi		ZL,0x11		; EEPROM Addresss L
		ldi		ZH,0x00		; EEPROM Addresss H
		rcall	read_EEPROM
		rcall	OUTD

		ldi		ZL,low(Voltage_TX*2)
		ldi		ZH,high(Voltage_TX*2)
		clr		tmp
		rcall	PRINT
		ldi		ZL,0x0E		; EEPROM Addresss L
		ldi		ZH,0x00		; EEPROM Addresss H
		rcall	read_EEPROM
		rcall	OUTH
		sbiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTH
		ldi		ZL,low(SER_NO_TX*2)
		ldi		ZH,high(SER_NO_TX*2)
		clr		tmp
		rcall	PRINT
		ldi		ZL,0x13		; EEPROM Addresss L
		ldi		ZH,0x00		; EEPROM Addresss H
		rcall	read_EEPROM
		rcall	OUTCH
		adiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTCH
		adiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTCH
		adiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTCH



; Sensor B
		ldi	ZL,low(SENSORB_TX*2)
		ldi	ZH,high(SENSORB_TX*2)
		clr	tmp
		rcall	PRINT

;* read EEPROM
		ldi		ZL,0x12		; EEPROM Addresss L
		ldi		ZH,0x00		; EEPROM Addresss H
		rcall	read_EEPROM
		rcall	OUTD

		ldi	ZL,low(Voltage_TX*2)
		ldi	ZH,high(Voltage_TX*2)
		clr	tmp
		rcall	PRINT
		ldi		ZL,0x10		; EEPROM Addresss L
		ldi		ZH,0x00		; EEPROM Addresss H
		rcall	read_EEPROM
		rcall	OUTH
		sbiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTH


		ldi		ZL,low(SER_NO_TX*2)
		ldi		ZH,high(SER_NO_TX*2)
		clr		tmp
		rcall	PRINT
		ldi		ZL,0x17		; EEPROM Addresss L
		ldi		ZH,0x00		; EEPROM Addresss H
		rcall	read_EEPROM
		rcall	OUTCH
		adiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTCH
		adiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTCH
		adiw	ZL,0x01
		rcall	read_EEPROM
		rcall	OUTCH



		ldi		comun_flags,0x03
		rjmp	MAIN_M		

READ_ADC_0:	; send ADC value
		rcall	OUTCH						; ECHO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;DISPLAY_TEMP:

		lds		fbinH,tem_h0
		lds		fbinL,tem_l0
		ldi		temp,0x02
		sub		fbinH,temp

		sbrc	fbinH,0x1
		rcall		negative

		rcall	bin2BCD16
		mov		temp,tBCD1

		rcall	OUTHR
		mov		temp,tBCD0
		swap	temp
		rcall	OUTHR
		ldi		temp,'.'
		rcall	OUTCH

		mov		temp,tBCD0
;		swap	temp
		rcall	OUTHR

		ldi		comun_flags,0x03
		rjmp	MAIN_M				

negative:
		com		fbinH
		com		fbinL
		ldi		temp,0x01
		add		fbinL,temp
		brcc	negative_1
		add		fbinH,temp
negative_1:
		ldi		temp,'-'
		rcall	OUTCH
		ret





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
READ_ADC_1:	; send ADC value
		rcall	OUTCH						; ECHO
		lds		temp,tem_h1	;
		rcall	OUTHR		;
		lds		temp,tem_l1	;
		rcall	OUTH
		ldi		comun_flags,0x03
		rjmp	MAIN_M
;
READ_ADC_2:	; send ADC value
		rcall	OUTCH						; ECHO
		lds		temp,tem_h2	;
		rcall	OUTHR		;
		lds		temp,tem_l2	;
		rcall	OUTH
		ldi		comun_flags,0x03
		rjmp	MAIN_M
;
READ_ADC_3:	; send ADC value
		rcall	OUTCH						; ECHO
		lds		temp,tem_h3	;
		rcall	OUTHR		;
		lds		temp,tem_l3	;
		rcall	OUTH
		ldi		comun_flags,0x03
		rjmp	MAIN_M
;
PRINT_HELP:
		rcall	OUTCH						; ECHO
		rcall	help
		rcall	READ_SENSOR_DATA
		ldi		comun_flags,0x03
		rjmp	MAIN_M


;
;------------------------------------------------------------
; get ASCII --> one HEX value  --> temp  ( upper case only )
;------------------------------------------------------------
HEX_IN:	cpi		temp,13		; CR	?
;		breq	HEX_IN_FIT	;
		subi	temp,0x30	; ascii --> hex
		brmi	NEXT_HEX_N   	;
		cpi		temp,0x0A	; digit ?
		brmi	HEX_RET		; yes
		cpi		temp,0x11	; < A ?
		brmi	NEXT_HEX_N  		; yes, error
		cpi		temp,0x17	; > F ?
		brmi	HEX_SO		; yes, error
		rjmp	NEXT_HEX_N      	; wait for hex number
;
HEX_SO:	subi	temp,0x07	; 0A...0F


HEX_RET:
		ST		Y+,temp;	; save
		sbrc	flags,echo_f
		rcall	OUTHR		; ECHO only hex value
		inc		count
		cp		count,HEX_N_NO
		brne	NEXT_HEX_N

HEX_IN_FIT_0:		
;		mov		count,HEX_N_NO
HEX_IN_FIT:
		dec		count
		brmi	HEX_IN_END
		LD		temp,-Y	
		st		X,temp
		dec		count
		brmi	HEX_IN_END
		LD		tmp,-Y
		swap	tmp
		add		temp,tmp
		st		X+,temp
		rjmp	HEX_IN_FIT
			
HEX_IN_END:
		ldi		comun_flags,0x03
		sec
		ret
NEXT_HEX_N:
		clc
		ret

;*******************************************
; voltage/temperatur compensation
;*******************************************
;
temp_comp:
		push	AH
		push	AL
		push	BH
		push	BL
		push	CH
		push	CMH
		push	CML
		push	CL
		lds		BL,tem_l0
		lds		BH,tem_h0

		ldi		AH,0x02
		ldi		AL,0xF9

		sub		AL,BL;0xF9;250	;25,0 grad C 0.1 grad/count
		sbc		AH,BH
		lds		BL,V_coif_ad 
		clr		BH
;
		rcall	mul16x16_16

		mov		BH,CML
		mov		BL,CL

		ldi		AH,0x19			;divide by 10 (0.1 deg temperature resulution)
		ldi		AL,0x9B;B;A
		rcall	muls16x16_32

		sts		V_com_fact_L,CMH
		sts		V_com_fact_H,CH

comp_b:
		lds		AH,V20b_H
		lds		AL,V20b_L
		ldi		tmp,0x00
		cp		AL,tmp
		cpc		AH,tmp
		breq	comp_b_2
		add		AL,CMH
		adc		AH,CH
comp_b_2:
		sts		V_compbH,AH
		sts		V_compbL,AL

V_offset_b:
		lds		BL,v_off_bL
		lds		BH,v_off_bH
		add		AL,BL
		adc		AH,BH
		brpl	V_gain_b
		ldi		AH,0x00
		ldi		AL,0x00
V_gain_b:
		lds		BL,v_gain_b_L
		lds		BH,v_gain_b_H
		rcall	mul16x16_32
		sts		V_corrb_H,CH
		sts		V_corrb_L,CMH

comp_a:
		lds		BH,V_com_fact_H
		lds		BL,V_com_fact_L
		lds		AH,V20a_H
		lds		AL,V20a_L
		ldi		tmp,0x00
		cp		AL,tmp
		cpc		AH,tmp
		breq	comp_a_2
		add		AL,BL
		adc		AH,BH
comp_a_2:
		sts		V_compaH,AH
		sts		V_compaL,AL

V_offset_a:
		lds		BL,v_off_aL
		lds		BH,v_off_aH
		add		AL,BL
		adc		AH,BH
		brpl	V_gain_a
		ldi		AH,0x00
		ldi		AL,0x00
V_gain_a:
		lds		BL,v_gain_a_L
		lds		BH,v_gain_a_H
		rcall	mul16x16_32
		sts		V_corra_H,CH
		sts		V_corra_L,CMH

		pop	CL
		pop	CML
		pop	CMH
		pop	CH
		pop	BL
		pop	BH
		pop AL
		pop	AH
		ret	

;**************************************************
;*******************************************************************
COMAND_6:							; set temp
		rcall	OUTCH				; ECHO
		ldi		comun_flags,0x0c
		rjmp	MAIN_M				

COMAND_6_S:							; 
		rcall	HEX_N
		push	temp
		rcall	INHEX
		pop		tmp
		swap	tmp
		add		temp,tmp
		sts		0x140,temp
		mov		AL,temp
		ldi		AH,0x0F
		ldi		BL,0x00
		ldi		BH,0x40
		rcall	fmul16x16_32; mul16x16_32;
		mov		temp,CH
		rcall	OUTH
		mov		temp,CMH
		rcall	OUTH
		mov		temp,CML
		rcall	OUTH
		mov		temp,CL
		rcall	OUTH
;COMAND_6_S_2:

		ldi		comun_flags,0x03
		rjmp	MAIN_M

COMAND_7:	; send compensated voltage
		rcall	OUTCH						; ECHO
		lds		temp,V_compbH
		rcall	OUTHR
		lds		temp,V_compbL
		rcall	OUTH
		ldi		comun_flags,0x03
		rjmp	MAIN_M

;*******************************************************************
;*******************************************************************
;*******************************************************************
CALL_OFFS_0:
		rcall	OUTCH				; ECHO
		ldi		comun_flags,0x0e
		rjmp	MAIN_M				
CALL_OFFS:
		lds		tmp,v_off_aL
		cpi		temp,'+'
		breq	inc_voff
		cpi		temp,'-'
		breq	dec_voff
;		cpi		temp,'X'
;		breq	CALL_GAIN_0
		cpi		temp,'S'
		breq	sav_call
		rjmp	MAIN_M
inc_voff:
		inc		tmp
		rjmp	CALL_OFFS_2
dec_voff:
		dec		tmp

CALL_OFFS_2:
		sts		v_off_aL,tmp
		mov		temp,tmp
		rcall	OUTH
		rjmp	MAIN_M



;*******************************************************************
;*******************************************************************
CALL_GAIN_0:
		rcall	OUTCH				; ECHO
		ldi		comun_flags,0x0f
		rjmp	MAIN_M				
CALL_GAIN:
		lds		ZL,v_gain_b_L
		lds		ZH,v_gain_b_H
		cpi		temp,'+'
		breq	inc_vgain
		cpi		temp,'-'
		breq	dec_vgain
;		cpi		temp,'Y'
;		breq	CALL_OFFS_0
		cpi		temp,'S'
		breq	sav_call
		rjmp	MAIN_M
inc_vgain:
		adiw	Z,0x01
		rjmp	CALL_GAIN_2
dec_vgain:
		sbiw	Z,0x01


CALL_GAIN_2:
		sts		v_gain_b_L,ZL
		sts		v_gain_b_H,ZH
		mov		temp,ZH
		rcall	OUTH
		mov		temp,ZL
		rcall	OUTH
		rjmp	MAIN_M

CALL_EXIT:
		ldi		comun_flags,0x03
		rjmp	MAIN_M
sav_call:
		rcall	OUTCH
		ldi		XL,0x00
;		ldi		ZL,low(ds1820_id_ad)
;		ldi		ZH,high(ds1820_id_ad)
		ldi		tmp,0x08
		rcall	write_ee
		ldi		ZL,low(v_off_aL)
		ldi		ZH,high(v_off_aL)
		ldi		tmp,0x03
		rcall	write_ee
		ldi		comun_flags,0x03
		cbr		flags,(1<<ds_err_f)
;		cbr		flags,(1<<call_f)
		rjmp	MAIN_M


;********************************************************************
DAC_UPDATE:

	cbr 	flags,(1<<seco_f)
	rcall	temp_comp

	ldi		temp,0x31
	cbi		PORTB,PB2		; CS low					; DAC Chanel 0 writethrough
	rcall	SPITransfer
	lds		temp,V_corra_H
	swap	temp
	lds		tmp,V_corra_L
	swap	tmp
	andi	tmp,0x0f
	or		temp,tmp
;lds		temp,V_corra_H
;lds		tmp,V_corra_L
;lsl		tmp
;rol		temp
;lsl		tmp
;rol		temp
;rcall	SPITransfer
;mov		temp,tmp
;rcall	SPITransfer
	rcall	SPITransfer
lds		temp,V_corra_L
swap	temp
andi	temp,0xf0
	rcall	SPITransfer
	sbi		PORTB,PB2		; CS 

ldi		temp,0x32
cbi		PORTB,PB2		; CS low					; DAC Chanel 0 writethrough
rcall	SPITransfer
lds		temp,V_corrb_H 
swap	temp
lds		tmp,V_corrb_L
swap	tmp
andi	tmp,0x0f
or		temp,tmp
rcall	SPITransfer
lds		temp,V_corrb_L 
swap	temp
andi	temp,0xf0
rcall	SPITransfer
sbi		PORTB,PB2		; CS 


ret



;********************************************************************
READ_SPI_16:
	cbi		PORTB,PB2		; CS low
	nop
	nop
	ldi		temp,0x00
	rcall	SPITransfer
	rcall	OUTH
	ldi		temp,0x00		
	rcall	SPITransfer
	rcall	OUTH
rjmp	READ_SPI_16_ret


READ_SPI_16_ret:
	sbi		PORTB,PB2		;CS high
	ret


;***********************************************
;*	SPI
;***********************************************

SPITransfer:
	out 	SPDR,temp
SPITransfer_loop:
	in		temp,SPSR
	sbrs	temp,SPIF
	rjmp 	SPITransfer_loop
	in 		temp,SPDR
	ret	
;*************************************************
; SPI write only h byte in temp, L byte in tmp
;*************************************************

;SPI_WRITE_16:
;	push		temp
;	in		temp,SPSR
;	sbrs	temp,SPIF
;	rjmp 	SPI_WRITE_16
;	pop		temp
;	out 	SPDR,temp
;SPI_WRITE_8:
;	in		temp,SPSR
;	sbrs	temp,SPIF
;	rjmp 	SPI_WRITE_8
;	out 	SPDR,tmp
;	ret	

;PR_HELP:
;		rcall	OUTCH						; ECHO
;		ldi		ZL,low(HELP_TX*2)
;		ldi		ZH,high(HELP_TX*2)
;		rcall	PRI_LCD
;		ldi		comun_flags,0x03
;		rjmp	MAIN_M



;******************************************************************************
;*
;* FUNCTION
;*	fmuls16x16_32
;* DECRIPTION
;*	Signed fractional multiply of two 16bits numbers with 32bits result.
;* USAGE
;*	r19:r18:r17:r16 = ( r23:r22 * r21:r20 ) << 1
;* STATISTICS
;*	Cycles :	20 + ret
;*	Words :		16 + ret
;*	Register usage: r0 to r2 and r16 to r23 (11 registers)
;* NOTE
;*	The routine is non-destructive to the operands.
;*
;******************************************************************************

fmul16x16_32:

	clr		r2
	fmul	r23, r21		; ( (signed)ah * (signed)bh ) << 1
	movw	r19:r18, r1:r0
	fmul	r22, r20		; ( al * bl ) << 1
	adc		r18, r2
	movw	r17:r16, r1:r0
	fmul	r23, r20		; ( (signed)ah * bl ) << 1
	adc		r19, r2
	add		r17, r0
	adc		r18, r1
	adc		r19, r2
	fmul	r21, r22		; ( (signed)bh * al ) << 1
	adc		r19, r2
	add		r17, r0
	adc		r18, r1
	adc		r19, r2
	ret
;******************************************************************************
;*
;* FUNCTION
;*	mul16x16_16
;* DECRIPTION
;*	Multiply of two 16bits numbers with 16bits result.
;* USAGE
;*	r17:r16 = r23:r22 * r21:r20
;* STATISTICS
;*	Cycles :	9 + ret
;*	Words :		6 + ret
;*	Register usage: r0, r1 and r16 to r23 (8 registers)
;* NOTE
;*	Full orthogonality i.e. any register pair can be used as long as
;*	the result and the two operands does not share register pairs.
;*	The routine is non-destructive to the operands.
;*
;******************************************************************************

mul16x16_16:
	mul	r22, r20		; al * bl
	movw	r17:r16, r1:r0
	mul	r23, r20		; ah * bl
	add	r17, r0
	mul	r21, r22		; bh * al
	add	r17, r0
	ret
;******************************************************************************
;*
;* FUNCTION
;*	mul16x16_32
;* DECRIPTION
;*	Unsigned multiply of two 16bits numbers with 32bits result.
;* USAGE
;*	r19:r18:r17:r16 = r23:r22 * r21:r20
;* STATISTICS
;*	Cycles :	17 + ret
;*	Words :		13 + ret
;*	Register usage: r0 to r2 and r16 to r23 (11 registers)
;* NOTE
;*	Full orthogonality i.e. any register pair can be used as long as
;*	the 32bit result and the two operands does not share register pairs.
;*	The routine is non-destructive to the operands.
;*
;******************************************************************************

mul16x16_32:
	clr	r2
	mul	r23, r21		; ah * bh
	movw	r19:r18, r1:r0
	mul	r22, r20		; al * bl
	movw	r17:r16, r1:r0
	mul	r23, r20		; ah * bl
	add	r17, r0
	adc	r18, r1
	adc	r19, r2
	mul	r21, r22		; bh * al
	add	r17, r0
	adc	r18, r1
	adc	r19, r2
	ret
;******************************************************************************
;*
;* FUNCTION
;*	muls16x16_32
;* DECRIPTION
;*	Signed multiply of two 16bits numbers with 32bits result.
;* USAGE
;*	r19:r18:r17:r16 = r23:r22 * r21:r20
;* STATISTICS
;*	Cycles :	19 + ret
;*	Words :		15 + ret
;*	Register usage: r0 to r2 and r16 to r23 (11 registers)
;* NOTE
;*	The routine is non-destructive to the operands.
;*
;******************************************************************************

muls16x16_32:
	clr	r2
	muls	r23, r21		; (signed)ah * (signed)bh
	movw	r19:r18, r1:r0
	mul	r22, r20		; al * bl
	movw	r17:r16, r1:r0
	mulsu	r23, r20		; (signed)ah * bl
	sbc	r19, r2
	add	r17, r0
	adc	r18, r1
	adc	r19, r2
	mulsu	r21, r22		; (signed)bh * al
	sbc	r19, r2
	add	r17, r0
	adc	r18, r1
	adc	r19, r2
	ret
;***
;
;**************************************************************************
;*	write to eeprom source address in Z destination in X
;*	tmp loop counter
;**************************************************************************
;****
;save_sw_time_1:
;		ldi		tmp,0x04			; loop counter # of bytes
;		ldi		YH,0x00				; ee start address
;		ldi		YL,0x00
;		clr		ZH					; pointer to data sourse
;		ldi		ZL,swti_1_on_ho
;		cbr		flags,(1<<save_f)	; clr flag
;***********
write_ee:
		cli	
write_ee_1:
		ld		temp,Z+				; get data
write_ee_2:				
		sbic 	EECR,EEWE			; Wait for completion of previous write
		rjmp 	write_ee_2
;		out 	EEARH, XH			; Set up address in address register
		out 	EEARL, XL						
		out 	EEDR,temp			; Write data (r16) to Data Register						
		sbi 	EECR,EEMWE			; Write logical one to EEMWE						
		sbi 	EECR,EEWE			; Start eeprom write by setting EEWE
		adiw	XL,0x01
		dec		tmp
		brne	write_ee_1
		sei
		ret

;**************************************************
read_EEPROM:				; Wait for completion of previous write
	sbic 	EECR,EEPE
	rjmp 	read_EEPROM						
	out 	EEARH,ZH
	out 	EEARL,ZL						; Start eeprom read by writing EERE
	sbi 	EECR,EERE						; Read data from Data Register
	in 		temp,EEDR
	ret
;****************************************************************************
;***** 	Timer0 Overflow Interrupt service routine 				*************
;***** Updates x ms, to provide time reference 					*************
;****************************************************************************

tick:	push	temp
		in		temp,SREG
		push	temp		
			inc 	tock		;add one to 20 ms 'tock' counter
			cpi 	tock,50;100	;is one second up?
			breq 	onesec		;yes, add one to seconds

			cpi		tock,25
			breq	halvs
			cpi		tock,75
			breq	halvs	
			rjmp	nosecond
halvs:		sbr 	flags,(1<<hsec_f)  	;0x10
			rjmp 	nosecond			;no, escape


		
onesec:		sbr 	flags,(1<<seco_f) 	;0x20	; new second flag
			clr 	tock				;clear 5 ms counter


nosecond:	ldi 	temp,178	;100  ;(8MHz/1024)/(256-100) ~ 20ms
			out 	TCNT0,temp		
		pop		temp
		out		SREG,temp  	;out SREG,status	;restore status register
		pop		temp
		reti			;return to main
;
TX_COMPLETE:
		push	temp
		cbi		ENA_PORT,ENA_PIN
	ldi	temp,0x58		; 0x18 Txena,Rxena; 0x58 Txena, TxIena, Rxena
	sts	UCSR0B,temp
		pop	temp
		reti

;	
.include "BASIC_IO.asm"
.include "ADC_INPUT.asm"
;

MEN_1_TAB:
;	0x20( ),0x21(!),0x22("),0x23(#),0x24($),0x25(%),0x26(&),0x27(`),0x28((),0x29()),0x2A(*),0x2B(+),0x2C(,),0x2D(-),0x2E(.),0x2F(/)
.dw	NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA

;	0x30(0),0x31(1),0x32(2),0x33(3),0x34(4),0x35(5),0x36(6),0x37(7),0x38(8),0x39(9),0x3a(:),0x3b(;),0x3c(<),0x3d(=),0x3e(>),0x3F(?)
.dw	NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA

;	0x40(@), 0x41(A) ,0x42(B), 	0x43(C),  0x44(D), 0x45(E),0x46(F),      0x47(G),0x48(H),  0x49(I),   0x4A(J),  0x4B(K),   0x4C(L),   0x4D(M),0x4E(N),0x4F(O)
.dw	NO_COMA,GET_V20A,GET_V20B,GET_VT_COIF,READ_Va ,READ_Vb,READ_VT_COIF,NO_COMA,PRINT_HELP,READ_ADC_0,READ_ADC_1,READ_ADC_2,READ_ADC_3,NO_COMA,NO_COMA,NO_COMA

;	0x50(P),0x51(Q),0x52(R),0x53(S),         0x54(T),0x55(U),0x56(V),0x57(W),0x58(X),0x59(Y),0x5A(Z),0x5B([),0x5C(),0x5D(]),0x5E(^),0x5F(_)
.dw	NO_COMA,NO_COMA,NO_COMA,READ_SENSOR_DATA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA

;	0x60(\),0x61(a),0x62(b),0x63(c),0x64(d),0x65(e),0x66(f),0x67(g),0x68(h),0x69(i),0x6A(j),0x6B(k),0x6C(l),0x6D(m),0x6E(n),0x6F(o)
.dw	NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA

;	0x70(p),0x71(q),0x72(r),0x73(s),0x74(t),0x75(u),0x76(v),0x77(w),0x78(x),0x79(y),0x7A(z),0x7B({),0x7C(|),0x7D(}),0x7E(->),0x7F(<-)
.dw	NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA

.dw	NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA
.dw	NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA
.dw	NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA,NO_COMA


MEN_TAB:
;COM_FLAGS 0	1			2		3			4		5
.dw	C_FLAGS_0,C_FLAGS_1,C_FLAGS_2,C_FLAGS_3,GET_HEX,COMAND_4,COMAND_4,COMAND_4,COMAND_4,COMAND_4,COMAND_A,COMAND_B,COMAND_C
.dw COMAND_D,CALL_OFFS,CALL_GAIN_0

;****************************************
;          TEXT STRING
;****************************************
HTEXT:	.db 10,13
	.db "SIPM_CONTROL D V0 "
	.db 10,00
	.db 00,00	
AUXPMT:	.db 13,10
	.db "* "
	.db  00,00

ERR_TX: .db 10,13
	.db "? "
	.db  00,00
MODUL_TX:
	.db 10,13,"Module No.: "
	.db  00,00
SENSORA_TX:
	.db 10,13,"Sensor A No.: "
	.db  00,00
SENSORB_TX:
	.db 10,13,"Sensor B No.: "
	.db  00,00
VOLTAGE_TX:
	.db " Voltage:"
	.db  00,00
SER_NO_TX:
	.db " SerNo.:"
	.db	00,00
;--------------------------------------------------------------------------
HELP_TX:
	.db 10,13
	.db "HW Version x.x  SW Version 1.0"
	.db 10,13
	.db "Commands: "
	.db 10,13
	.db "'<' Start Delimiter "
	.db 10,13
	.db "'>' Stop Delimiter"
	.db 10,13
	.db "'A' Set Bias Voltage Sensor A "
	.db 10,13
	.db "'B' Set Bias Voltage Sensor B "
	.db 10,13.
    .db "'C' Set Bias Voltage Progression Coefficient 0...F (20mV/K)/Count "
	.db 10,13
	.db "'D' Read Temperature Adjusted Voltage Sensor A (Calculated) "
	.db 10,13
	.db "'E' Read Temperature Adjusted Voltage Sensor B (Calculated) "
	.db 10,13
	.db "'F' Read Progression Coefficient"
;	.db 10,13		
	.db "'I' Read Temperature"
	.db 10,13			
	.db "'H' Print this list "
	.db 10,13
	.db "Returns:"		
	.db 10,13
	.db "'*'  OK ready "
	.db 10,13
	.db "'?'  Error"
	.db 10,13
	.db 00, 00
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
	
 
	


