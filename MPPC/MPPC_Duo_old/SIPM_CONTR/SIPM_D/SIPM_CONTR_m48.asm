
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
			  
.include "m48def.inc"
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
.equ	ENA_PIN = PORTD2
.equ	ADDR_PORT = PORTC

			
;**** Global Register Variables ****

; r0 to r2 and r16 to r23 (11 registers)
; r19:r18:r17:r16 = ( r23:r22 * r21:r20 ) << 1

;.equ			= r0
;.equ			= r1
;.equ			= r2
.def	own_add	= r3
;.equ			= r4
;.equ			= r5
;.equ			= r6
;.equ			= r7
;.equ			= r8
;.equ			= r9
.equ	AtBCD0	=10		;address of tBCD0
.equ	AtBCD2	=12		;address of tBCD1
.def	tBCD0	=r10	;BCD value digits 1 and 0
.def	tBCD1	=r11	;BCD value digits 3 and 2
.def	tBCD2	=r12	;BCD value digit 4
.def	fbinH	=r5		;binary value Low byte
.def	fbinL	=r4		;binary value High byte

;.def	count	=r22	; ds1820 / Basic_IO 

.def	t_crc		= r13;r21	; ds1820 
.def	value		= r14		; ds1820 
.def	mask		= r15		; ds1820 
;	= r16
;	= r17
;	= r18
;	= r19
.def 	wait		= r20		; ds1820 
.def	count		= r21		; ds1820 / Basic_IO 
.def	error		= r22		; ds1820 
.def	temp		= r23		; scratch 
.def	flags		= r24
.def	tmp			= r25
;.def	XL			= r26		; already def by xxxxdef.inc file
;.def	XH			= r27		        ; 
.def	comun_flags = r28
.def	tock		= r29
;.def	YL	=r28
;.def	YH	=r29
;.def	ZL	=r30
;.def	ZH	=r31

.def	AH = r23
.def	AL = r22
.def	BH = r21
.def	BL = r20
.def 	CH = r19
.def	CMH= r18
.def	CML= r17
.def	CL = r16

;**************************
;*	flag register bit def.
;**************************
.equ	tick_f		= 7	;flags
.equ	seco_f		= 6
.equ	DS1820_trigger_f =5
.equ	call_f		= 4
.equ	first_f		= 3
.equ	ds_err_f = 2

.equ	com_stop_con = '>';0x1B	; ESC = Stop
.equ	com_start_con = 0x3C ; < = Start

;******************************************
;*	dseg
;******************************************
.equ	ds1820_id_sbad =0x100 ;.....0x107
.equ	v_off_ad= 0x108
.equ	v_gain_ad_H= 0x109
.equ	v_gain_ad_L= 0x10A

.equ	Th_is_L = 0x110
.equ	Th_is_H = 0x111	;.....0x118

.equ	V20_inH = 0x120
.equ	V20_inL = 0x121
.equ	V_coif_ad = 0x124;11D
.equ	V20_sbH	= 0x125;11E
.equ	V20_sbL = 0x126;11F
.equ	V_compH	= 0x127;120
.equ	V_compL = 0x128;121
.equ	V_corrH = 0x129;122
.equ	V_corrL = 0x12A;123

.equ	C_thres_H = 0x12B;122
.equ	C_thres_L = 0x12C;123
.equ	ds1820_id_ad = 0x130;124 ;...0x12B

.eseg
;.db 0x28,0x85,0x49,0x48,0x02,0x00,0x00,0xB6,0x02,0x7F,0xC9 	; Module 0
;.db 0x28,0x68,0xC1,0x10,0x01,0x00,0x00,0x00,0x00,0x7E,0xD8	; Module I
;.db 0x28,0xC6,0x25,0x48,0x02,0x00,0x00,0xAA,0x0F,0x7F,0x60
;.db 0x28,0x29,0xE0,0xFC,0x01,0x00,0x00,0x2C,0x04,0x77,0x52	; Module 3
;.db 0x28,0xC7,0xED,0xFF,0x01,0x00,0x00,0x72,0x04,0x77,0x52	; Module 4
.db 0x28,0xA2,0xF4,0xFF,0x01,0x00,0x00,0xD5,0x02,0x77,0x37	; Module 5
;28A2F4FF010000D5027737
;28854948020000B6037F8E
;28854948020000B6037F95
;28C62548020000AA0F7F60
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


	ldi	temp,0x00	
;	out	UBRRH,temp	
	sts	UBRR0H,temp
	ldi	temp,0x19;02 ;9600; 0C	; BAUD RATE = 9600,0x0C - 2MHz; 0x17 - 3,686 MHz  
;	out	UBRRL,temp	;	      	  ,0x19 - 4MHz, 0x0C - 19200
	sts	UBRR0L,temp
	ldi	temp,0x00
	sts	UCSR0A,temp
	ldi	temp,0x58		; 0x18 Txena,Rxena; 0x58 Txena, TxIena, Rxena
	sts	UCSR0B,temp

	ldi	temp,0x06
;	out	UCSRC,temp
	sts	UCSR0C,temp

;	ldi	temp,0x2f;4d		;0x5b
;	sts	OSCCAL,temp

; Init Timer 0			
	ldi 	temp,0x05		;timer prescalar 0x03=/64;0x04=/256;0x05 =/1024
	out 	TCCR0B,temp
	ldi 	temp,0x00
	out 	TCCR0A,temp
	out 	TCNT0,temp		;(256 - n)*256*0.2441 us
	ldi 	temp,1			;enable timer interrupts
	sts 	TIMSK0,temp	
;* Init Timer 2 PWN
;##	ldi		temp,0x21		;31
;##	sts		TCCR2A,temp
;##	ldi		temp,0x07		;prescaler /1024
;##	sts		TCCR2B,temp
;##	sbi		DDRD,PD3				;!!!!!!!!!!!!!!PD3 OUT verursacht Störungen
;##	ldi		temp,0xf0
;##	sts		OCR2B,temp

;* read EEPROM
		ldi		XL,0x00		; EEPROM Addresss
		ldi		ZL,0x00		; RAM Address
		ldi		ZH,0x01
		ldi		tmp,0x0B	; Byts #
EEPROM_read:				; Wait for completion of previous write
	sbic 	EECR,EEWE
	rjmp 	EEPROM_read
						; Set up address (r18:r17) in Address Register
;	out 	EEARH,XH
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
Init_RAM_1:
	st		Z+,temp
	cpi		ZL,0x28
	brne	Init_RAM_1

;*	SPI Interface (master)
	sbi		PORTB,PB2
	sbi		DDRB,PB2	;ENA* = Output
	cbi		DDRB,PB4	;MISO= input
	sbi		DDRB,PB3	;MOSI= output
	sbi		DDRB,PB5	;SCK = Output
	ldi		temp,0x52	; SPI Master ena, clk/
	out		SPCR,temp
;*
	sbi		(ENA_PORT-1), ENA_PIN		;RS driver enable

	cbi		(OW_BUS_PORT),OW_BUS_PIN	;
	cbi		(OW_BUS_PORT-1),OW_BUS_PIN	; input	
	ldi		temp,0x3e
	out		ADDR_PORT,temp			; input pullup on	
	cbi		PORTD,PD2				; Tx enable pin
	sbi		DDRD,PD2

;***************************************************************************
	clr		comun_flags
	ldi		flags,(1<<first_f)
	rcall 	ds1820_sensorid			; get ds1820 address
	sei
	in		temp,(ADDR_PORT-2)		; get own address
	sbrc	temp,0x1
	sbr		temp,0x40
	lsr		temp
	lsr		temp
	com		temp
	andi	temp,0x1f
	mov		own_add,temp
	sbi		(ENA_PORT-1), ENA_PIN		;RS driver enable

;***
	ldi		ZL,low(ds1820_id_sbad)
	ldi		ZH,high(ds1820_id_sbad)

check_ds1820:
	ld		AL,Z+
	ldd		BL,Z+0x2F
	cp		AL,BL
	brne	ds_ERR
	cpi		ZL,(low(ds1820_id_sbad+0x08))		
	brne	check_ds1820
	rjmp	MAIN_M_1
ds_ERR:
	sbr		flags,(1<<ds_err_f)


	rjmp	MAIN_M_1
;***********************************************************************************
MAIN_M:	ldi		temp,10
		rcall	OUTCH
		ldi		temp,13
		rcall	OUTCH
		ldi		temp,'*'
		sbrc	flags,ds_err_f
		ldi		temp,'?'	
		rcall	OUTCH


MAIN_M_1:

;rjmp	MAIN_M_1

		sbrc	flags,seco_f
		rcall	temp_contr
;nop
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

COM_STOP:
		clr		comun_flags
		cbi		ENA_PORT,ENA_PIN	;disable driver
		rjmp	MAIN_M_1

C_FLAGS_0:								; start ?
		cpi		temp,com_start_con
		brne	MAIN_M_1
		ldi		comun_flags,0x01
		rjmp	MAIN_M_1


C_FLAGS_1:								; own address
		ldi		comun_flags,0x02

C_HEX_N:subi	temp,0x30	; ascii --> hex
		brmi	C_HEX_E   	;
		cpi		temp,0x0A	; digit ?
		brmi	C_HEX_R		; yes
		cpi		temp,0x11	; < A ?
		brmi	C_HEX_E  		; yes, error
		cpi		temp,0x17	; > F ?
		brmi	C_HEX_S		; yes, error
C_HEX_E:rjmp	MAIN_M_1      	; wait for hex number
;
C_HEX_S:subi	temp,0x07	; 0A...0F

C_HEX_R:cp		temp,own_add
		brne	MAIN_M_1
		ldi		comun_flags,0x03
		rcall	OUTHR					; echo own address
;		sbi		ENA_PORT,ENA_PIN


C_FLAGS_2:								; not own address
		rjmp	MAIN_M_1


C_FLAGS_3:
	
	sbrc	flags,first_f
	rcall	SET_CALL_MODE
		
		ldi		wait,0x07
		rcall	ds1820_waitus
		cpi		temp,'A'
		breq	COMAND_1		
		cpi		temp,'B'
		breq	COMAND_2
		cpi		temp,'C'
		breq	COMAND_3		
		cpi		temp,'D'
		breq	COMAN_4
		cpi		temp,'E'
		breq	COMAN_5
;		cpi		temp,'F'
;		breq	COMAN_6
		cpi		temp,'V'
		breq	COMAN_7
		cpi		temp,'F'
		breq	COMAN_8
		cpi		temp,'G'
		breq	COMAN_9
		cpi		temp,'H'
		breq	HELP_L
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

COMAN_4:
	rjmp	COMAND_4
COMAN_6:
	rjmp	COMAND_6
COMAN_5:
	rjmp	COMAND_5
COMAN_7:
	rjmp	COMAND_7
COMAN_8:
	rjmp	COMAND_8
COMAN_9:
	rjmp	COMAND_9
CALL_OFFS_00:
	rjmp	CALL_OFFS_0
CALL_GAIN_00:
	rjmp	CALL_GAIN_0
HELP_L:
		rcall	HELP
		ldi		comun_flags,0x03
		rjmp	MAIN_M

;measure temperature
COMAND_1:	
;		ldi		comun_flags,0x04
		rcall	OUTCH				; ECHO
		rcall	DS1820_SEND_DATA
;		rcall	ds1820_messen
		ldi		comun_flags,0x03
		rjmp	MAIN_M

; get ds1820 address							
COMAND_2:							
;		ldi		comun_flags,0x04
		rcall	OUTCH				; ECHO
		rcall 	ds1820_sensorid
		ldi		XL, low(ds1820_id_ad)
		ldi		XH, high(ds1820_id_ad)		; X: Anfang SRAM
		ldi 	count,8			; 8 Bytes lesen
send_sid_1:
		ld		temp,X+
		rcall	OUTH
		ldi		temp, ' '
		rcall	OUTCH
		dec 	count
		brne	send_sid_1			; 8 byte ?
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
;
;************************************************************
; set voltage
COMAND_4:							
		rcall	OUTCH						; ECHO
		ldi		comun_flags,0x08
		ldi		XL,low(V20_inH)
		ldi		XH,high(V20_inH)
		rjmp	MAIN_M				

COMAND_4_S:							; set voltage
		rcall	HEX_N
		st		X+,temp
		cpi		XL,low(V20_inH +3)
		brne	COMAND_4_S_END
		lds		AL,V20_inL			;tmp,V20_sbL
		swap	AL					;tmp
		add		AL,temp				;,tmp
		sts		V20_sbL,AL		
		lds		AH,V20_inH
		sts		V20_sbH,AH

	rcall	temp_comp
	rcall	V_offset
		ldi		comun_flags,0x03
		rjmp	MAIN_M
COMAND_4_S_END:
		rjmp	MAIN_M_1

;*******************************************
; voltage/temperatur compensation
;*******************************************
;
temp_comp:
	lds		AH,V20_sbH
	lds		AL,V20_sbL
	lds		BL,Th_is_L
	lds		BH,Th_is_H
	lsr		BH
	ror		BL
	lsr		BH
	ror		BL
	lsr		BH
	ror		BL
	subi	BL,0x32		;25,0 grad C 0.5 grad/count
	lds		tmp,V_coif_ad
	muls	BL,tmp
	movw	BL,r0

;	clc
	clr		tmp
	sbrc	BH,7
;	sec
	ldi		tmp,0x03
lsr		tmp
	ror		BH			;
	ror		BL
;lsr		tmp
;	ror		BH			;
;	ror		BL
			
	add		AL,BL
	adc		AH,BH
	sts		V_compH,AH
	sts		V_compL,AL
	ret	

V_offset:
		lds		BL,v_off_ad
		sub		AL,BL
		sbci	AH,0x00
		brcc	V_offset_2
		ldi		AH,0x00
		ldi		AL,0x00
V_offset_2:

V_gain:
		lds		BL,v_gain_ad_L
		lds		BH,v_gain_ad_H
		rcall	fmul16x16_32
		sts		V_corrH,CH
		sts		V_corrL,CMH

		lds		temp,V_corrH
		cbi		PORTB,PB2		; CS low
		ori		temp,0xa0		; DAC channel
		rcall	SPITransfer
		lds		temp,V_corrL
		rcall	SPITransfer
		sbi		PORTB,PB2		;CS high
		ret


;**************************************************
COMAND_5:							; set threshold
		rcall	OUTCH				; ECHO
		ldi		comun_flags,0x0a
		ldi		XL,low(C_thres_H)
		ldi		XH,high(C_thres_H)
		rjmp	MAIN_M				

COMAND_5_S:

COMAND_5_S_1:
		rcall	HEX_N
		st		X+,temp
		cpi		XL,low(C_thres_H +3)
		brne	COMAND_5_S_END
		lds		tmp,C_thres_L
		swap	tmp
		add		temp,tmp

	sts		C_thres_L,temp
COMAND_5_S_2:
;	sts		0x120,temp

	lds		temp,C_thres_H
	cbi		PORTB,PB2		; CS low
	ori		temp,0x90
	rcall	SPITransfer
	lds		temp,C_thres_L
	rcall	SPITransfer
	sbi		PORTB,PB2		;CS high

		ldi		comun_flags,0x03
		rjmp	MAIN_M
COMAND_5_S_END:
		rjmp	MAIN_M_1				

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
COMAND_6_S_2:

		ldi		comun_flags,0x03
		rjmp	MAIN_M

COMAND_7:	; send compensated voltage
		rcall	OUTCH						; ECHO
		lds		temp,V_compH
		rcall	OUTHR
		lds		temp,V_compL
		rcall	OUTH
		ldi		comun_flags,0x03
		rjmp	MAIN_M


COMAND_8:	; set V compensated factor
		rcall	OUTCH						; ECHO
		ldi		comun_flags,0x0d
		rjmp	MAIN_M_1
COMAND_8_S:
		rcall	HEX_N
		sts		V_coif_ad,temp
		ldi		comun_flags,0x03
		rjmp	MAIN_M


COMAND_9:	; read V compensated factor
		rcall	OUTCH						; ECHO
		lds		temp,V_coif_ad
		rcall	OUTHR
		rjmp	MAIN_M
;*******************************************************************
CALL_OFFS_0:
		rcall	OUTCH				; ECHO
		ldi		comun_flags,0x0e
		rjmp	MAIN_M				
CALL_OFFS:
		lds		tmp,v_off_ad
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
		sts		v_off_ad,tmp
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
		lds		ZL,v_gain_ad_L
		lds		ZH,v_gain_ad_H
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
		sts		v_gain_ad_L,ZL
		sts		v_gain_ad_H,ZH
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
		ldi		ZL,low(ds1820_id_ad)
		ldi		ZH,high(ds1820_id_ad)
		ldi		tmp,0x08
		rcall	write_ee
		ldi		ZL,low(v_off_ad)
		ldi		ZH,high(v_off_ad)
		ldi		tmp,0x03
		rcall	write_ee
		ldi		comun_flags,0x03
		cbr		flags,(1<<ds_err_f)
;		cbr		flags,(1<<call_f)
		rjmp	MAIN_M


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

;	andi	temp,0x0F
;	mov		fbinH,temp
;	ldi		temp,0x00
;	rcall	SPITransfer

;	mov		fbinL,temp
;	lsl		fbinL		; * 2
;	rol		fbinH		;
;	rcall	bin2BCD16
;	mov		temp,tBCD2
;	mov		temp,tBCD1
;	rcall	OUTH
;	mov		temp,tBCD0
;	swap	temp
;	rcall	OUTH
;	ldi temp,'0'
;	rcall	OUTCH
;	ldi temp,'m'
;	rcall	OUTCH
;	ldi temp,'V'
;	rcall	OUTCH

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

;*******************************************
;
;*******************************************
temp_contr:
	cbr		flags,(1<<seco_f)

	sbrs	flags,DS1820_trigger_f
	rjmp	ds1820_ausloesen
nop
cbr		flags,(1<<DS1820_trigger_f)
nop
	rcall	ds1820_auslesen
nop
	rcall	temp_comp
	rcall	V_offset
	ret

;	lds		temp,0x111
;	lds		tmp,0x110
;
;	lds		fbinL,0x140
;	clr		fbinH
;	lsl		fbinL	
;	rol		fbinH
;
;	lsl		fbinL
;	rol		fbinH

;	lsl		fbinL
;	rol		fbinH

;	sub		tmp,fbinL
;	sbc		temp,fbinH

;	brcs	temp_contr_1
;	cpi		temp,0x00
;	breq	temp_contr_2

;temp_contr_3:
;	ldi		temp,0xff
;	sts		OCR2B,temp
;	ret

;temp_contr_1:
;	ldi		temp,0x00
;	sts		OCR2B,temp
;	ret
;temp_contr_2:
;	mov		temp,tmp
;	sts		OCR2B,temp
;	ret
;

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
			rjmp	nosecond
onesec:		sbr 	flags,(1<<seco_f) 	;0x20	; new second flag
			clr 	tock				;clear 5 ms counter


nosecond:	ldi 	temp,0x00	;100  ;(8MHz/1024)/(256-100) ~ 20ms
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
.include "OW_DS1820.asm"
.include "BASIC_IO.asm"
;

MEN_TAB:
.dw	C_FLAGS_0,C_FLAGS_1,C_FLAGS_2,C_FLAGS_3,COMAND_1,COMAND_2,COMAND_3,COMAND_4,COMAND_4_S,COMAND_5,COMAND_5_S,COMAND_6,COMAND_6_S
.dw COMAND_8_S,CALL_OFFS,CALL_GAIN

;****************************************
;          TEXT STRING
;****************************************
HTEXT:	.db 10,13
	.db "SIPM_CONTROL V0 "
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
	.db "Commands: "
	.db 10,13
	.db 10,13
	.db "'<' Start Delimiter "
	.db 10,13
	.db "'>' Stop Delimiter"
	.db 10,13
	.db "'A' Read Temperature"
	.db 10,13
	.db "'B' Read Temperature Sensor Address "
	.db 10,13
;	.db "'C' "
;	.db 10,13
	.db "'D' Set Bias Voltage @ 25 deg C  (000...FFF 20 mV/count)"
	.db 10,13
;	.db "'E' Set Threshold "
;	.db 10,13
	.db "'F' Set Bias Voltage Progression Coefficient 0...F (20mV/K)/Count "
	.db 10,13
	.db "'G' Read Progression Coefficient"
	.db 10,13		
	.db "'V' Read Temperature Adjusted Voltage (Calculated)"
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
	
 
	


