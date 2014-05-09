;***********************************************
;
;***********************************************
;TRIGGER:	
;		rcall	ds1820_ausloesen
;		rjmp 	MAIN	
;READ_T:	rcall 	ds1820_auslesen
;		rjmp 	MAIN
;MEAS_T: rcall	ds1820_messen
;		rjmp 	MAIN
;SET_PIN:
;	ldi	temp, ':'
;	rcall	OUTCH
;	rcall 	INHEX
;	inc 	temp
;	clr	dsp_neg
;	sec
;sett_01:rol	dsp_neg
;	dec	temp
;	brne	sett_01
;	push 	dsp_neg
;	com	dsp_neg
;	pop 	OW_BUS_PIN	
;	rjmp 	MAIN
	
;GET_ADDR:
;		rcall 	ds1820_sensorid
;		rjmp	MAIN
		
SET_ADDR:
		ldi		temp, 32		; Nur zur Bequemlichkeit,
		rcall 	OUTCH			; um vor _jeder_ Eingabe 
		ldi		temp, 32		; genau 5 Bytes zu 
		rcall 	OUTCH			; empfangen
		ldi		XL, 0x00
		ldi		XH, 0x01		; X zeigt auf SRAM Start
		ldi 	count,8
saddr_1:ldi 	temp, 10
		rcall 	OUTCH
		ldi	temp, 13
		rcall	OUTCH
		ldi	temp, ':'
		rcall 	OUTCH	
		rcall 	BYTE			; lies hex. Byte ein
		st	X+, temp		; speichern
		dec 	count
		brne	saddr_1
;	rcall	PRI_AUX
		rjmp 	MAIN_M
	
HELP_LS: 
		rcall HELP
		rjmp MAIN_M
	
;********************************************************
;* ds1820_wait: Warten von 6-1000 Mikrosekunden		*
;* Pro Zyklus 0.25 us					*
;* Wartezeit: (wait*4 + 2)us				*
;********************************************************

ds1820_wait:			; 3 cycles (rcall)
	lsl		wait		; x2 for 8MHz CPU	
ds1820_wait_1:
	nop			; 1 cycle	
	nop			; 1 cycle
	nop			; 1 cycle	
	nop			; 1 cycle
	nop			; 1 cycle	
	nop			; 1 cycle
	nop			; 1 cycle	
	nop			; 1 cycle
	nop			; 1 cycle	
	nop			; 1 cycle
	nop			; 1 cycle	
	nop			; 1 cycle
	nop			; 1 cycle	
	dec 	wait		; 1 cycle
	brne 	ds1820_wait_1	; 1/2 cycles
	ret			; 4 cycles
	
;********************************************************
;* ds1820_waitus: Warten von wenigen Mikrosekunden	*
;* Wartezeit: (wait + 2)us				*
;* Achtung: 1 Zyklus wird für den 'ldi' Befehl		*
;*          _vor_ dem Aufruf gebraucht!			*
;********************************************************

ds1820_waitus: 			; 3
	lsl		wait		; x2 for 8MHz CPU
ds1820_waitus_1:
	dec 	wait		; 1
	nop					; 1
	brne 	ds1820_waitus_1	; 2 (1)
	nop					; 1
	ret					; 4

;********************************************************
;* ds1820_waitms: Warten von einigen Millisekunden	*
;* Parameter: Z: Wartezeit in ms			*
;********************************************************

ds1820_waitms:			; 2 (rcall)
	ldi 	tmp, 250	; 1
	
wms1:	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1
	nop			; 1 (Summe: 14)
	dec 	tmp		; 1 
	brne	wms1		; 2 (1)
	sbiw	ZL, 1		; 2
	brne	ds1820_waitms	; 2 (1)
	
	ret			; 4
	
;********************************************************
;* ds1820_reset: 					*
;* Sensoren zurücksetzen und feststellen, ob mindestens	*
;* ein Sensor am Bus hängt				*
;* Rückgabewert: sensor=0 Sensor vorhanden		*
;*		 sensor=1 kein Sensor			*
;********************************************************

ds1820_reset:

	sbi	(OW_BUS_PORT-1),OW_BUS_PIN 
;	cbi		OW_BUS_PORT,OW_BUS_PIN  	;**out	, dsp_neg;	; PIN = 0
	ldi 	wait, 190	;200	
	rcall	ds1820_wait			; 502 us warten
	cbi		(OW_BUS_PORT-1),OW_BUS_PIN 	;**out	(OW_BUS_PORT-1), dsp_neg;	; PIN -> input
	ldi		wait, 20
	rcall 	ds1820_wait			; 82 us warten
;	clr		sensor	
	ldi		error,0x01
	ldi 	count,6				; 6 mal sampeln
res_00:	
	sbic 	(OW_BUS_PORT-2),OW_BUS_PIN 					 						
	rjmp	res_01			
	clr		error
;	ldi		sensor, 1			;	...sensor = 1
	rjmp	res_02			;	...Schleife verlassen
res_01:	ldi	wait, 10		; 42 us warten
	rcall	ds1820_wait
	dec 	count
	brne	res_00
res_02:	;nop;sei				; global interrupt enable
	ldi		wait, 50;150	
	rcall	ds1820_wait		; 600 us warten
	clr		t_crc				; Pruefsumme loeschen
	ret
	
;********************************************************
;* ds1820_writebit					*
;* 1 Bit zum DS1820 senden (Bit 0 von temp)		*
;********************************************************

ds1820_writebit:
;	cbi		OW_BUS_PORT,OW_BUS_PIN	
	sbi		(OW_BUS_PORT-1),OW_BUS_PIN	; output
	nop
	nop
	nop
	sbrc	temp ,0			; bit gesetzt ?
	cbi		(OW_BUS_PORT-1),OW_BUS_PIN	
	ldi		wait, 14	;20
	rcall 	ds1820_wait		; warte 80 us
	cbi		(OW_BUS_PORT-1),OW_BUS_PIN	;input
;	nop
;	nop
;	nop
;	nop				; warte 1 us
	ret
	
	
;********************************************************
;* ds1820_writebyte					*
;* schreibt ein komplettes Byte (temp) zum DS1820 	*
;********************************************************

ds1820_writebyte:
	ldi		count, 8
wb_1:	
	rcall	ds1820_writebit
	lsr		temp			; shift right
	dec		count
	brne	wb_1
	ret
	

;********************************************************
;* ds1820_readbit					*
;* 1 bit von DS1820 lesen				*
;* als Bit 0 von temp zurückgeben			*
;********************************************************

ds1820_readbit:
		push	count
		sbi		(OW_BUS_PORT-1),OW_BUS_PIN		; output
		nop
		nop
		nop				; bis hierher sind 4us vergangen

		cbi		(OW_BUS_PORT-1),OW_BUS_PIN		; input				
		ldi 	wait ,1
		rcall	ds1820_waitus		; warte 3 us
		clr		temp				; 1 clock
		ldi		count, 4		; 4 mal sampeln			1
							; bis hierher sind 8,25us vergangen
							; jeder Loop-Durchlauf:1,5us

rbit_00:sbis	(OW_BUS_PORT-2),OW_BUS_PIN	
		rjmp	rbit_01			; PIN == 1?			1/2		
		ldi		temp,1 			;	...temp=1		1
		rjmp	rbit_02			; 	...Schleife verlassen	2
rbit_01:dec 	count			;				1
		brne	rbit_00			;				1/2

rbit_02:ldi 	wait, 20
		rcall	ds1820_wait		; warte 80 us
		mov 	tmp, temp
		sbrc	t_crc, 0
		ori		tmp, 140
		lsr		t_crc
		eor		t_crc, tmp

		pop 	count
		ret
	
;********************************************************
;* ds1820_readbyte					*
;* 1 Byte von DS1820 (nach 'value') lesen		*
;* 							*
;********************************************************

ds1820_readbyte:
		ldi 	count, 8
		clr		temp
		mov 	value,temp
dr_s1:
		rcall 	ds1820_readbit
		ror 	temp
		ror		value
		dec 	count
		brne	dr_s1
;	mov	value, temp
	; highbyte loeschen ???
	
		ret
	
ds1820_ausloesen:
	sbr		flags,(1<<DS1820_trigger_f)
		push	XL
		push	XH
		ldi		error, 0
		rcall	ds1820_reset
;		cpi 	sensor, 1		; temp !=1?
;		breq	ausl_0			; 	zurueck
;		ldi		error, 1		; Fehlercode 1 (kein Sensor)
		sbrc	error,0
		rcall	PRI_ER
ausl_0:	ldi		temp, 0xcc
		rcall 	ds1820_writebyte
		ldi		temp, 0x44
		rcall 	ds1820_writebyte
		pop		XH
		pop		XL
		ret
	
ds1820_auslesen:
		push	XL
		push	XH
		cbr		flags,(1<<DS1820_trigger_f)
		clr		error
		rcall	ds1820_sel_adr
		cpi		error, 0
		breq	les_0
		ret
les_0:
		ldi		temp, 0xBE
		rcall	ds1820_writebyte
		ldi		XL,low(Th_is_L)
		ldi		XH,high(Th_is_L)
DS1820_READ_NEXT:
		rcall	ds1820_readbyte
		st		X+,value
		cpi		XL,(low(Th_is_L )+ 9) ;0x19
		brne	DS1820_READ_NEXT
		clr		t_crc
		breq	temp_1			; Prüfsumme != 0?
		ldi		error, 4			; Fehlercode 4 (Prüfsumme)
		rcall	PRI_ER	
temp_1:	
		pop		XH
		pop		XL
		ret

;******

DS1820_SEND_DATA:

		ldi		temp, 32
		rcall 	OUTCH
	lds	temp,Th_is_L ;0x110
	lds value,Th_is_H ;0x111
	sbrc value,0x7
	rcall	minus
	sts		(Th_is_L+2),temp

	lsr	value
	ror	temp
	lsr	value
	ror temp
	lsr	value
	ror	temp
	lsr	value
	ror temp
	rcall	OUTD
	ldi		temp,'.'
	rcall 	OUTCH

		lds		AL,(Th_is_L+2)
		andi	AL,0x0F
		lsr		AL
		ldi		BL,0x7d		;low()
		mul		AL,BL
		movw	r4,r0
		rcall	bin2BCD16
		mov		temp,tBCD1
		rcall	OUTHR	
		mov		temp,tBCD0
		rcall	OUTH
	ldi		temp,' '
	rcall 	OUTCH
	ldi		temp,'C'
	rcall 	OUTCH
		ret

minus:	push	temp
		ldi		temp,'-'
		rcall	OUTCH
		pop		temp
		com		value
		com		temp

		ret
;#endif

;#################################
ds1820_sel_all:
		clr 	error
		rcall	ds1820_reset
;		cpi 	sensor, 1		; temp !=1?
;		breq	sall_0			; 	Fehler
;		ldi		error, 1		; Fehlercode 1 (kein Sensor)
		sbrc	error,0
		rcall	PRI_ER			
sall_0:	ldi		temp, 0xcc
		rcall 	ds1820_writebyte
		ret
	
ds1820_sel_adr:
		clr 	error
		rcall	ds1820_reset
;		rcall	ds1820_reset
;		cpi 	sensor, 1		; temp !=1?
;		breq	sadr_0			; 	Fehler
;		ldi		error, 1		; Fehlercode 1 (kein Sensor)
		sbrc	error,0
		rcall	PRI_ER			
sadr_0:	ldi		temp, 0x55
		rcall 	ds1820_writebyte
		ldi 	count, 8
		ldi		XL, low(ds1820_id_ad)		; X: Anfang SRAM
		ldi		XH, high(ds1820_id_ad)
sel_adr_wr:
		ld		temp, X+
;		push	temp
;		rcall	OUTH
;		ldi		temp, 32
;		rcall 	OUTCH
;		pop 	temp
		push 	count
		rcall 	ds1820_writebyte
		pop 	count
		dec		count
		brne	sel_adr_wr
sel_adr_ende:
		ret


ds1820_sensorid:
		rcall 	ds1820_reset
		clr		error
		rcall 	ds1820_reset
;		cpi 	sensor, 1		; Sensor gefunden?
;		breq	sid_0
;		ldi		error, 1		; Fehlercode 1 (kein Sensor)
		sbrc	error,0
		rjmp	PRI_ER			
;		ret
sid_0:	;ldi		temp, 10
		;rcall 	OUTCH
		;ldi		temp, 13
		;rcall 	OUTCH
		;ldi		temp, ' '
		;rcall 	OUTCH
		ldi		temp, 0xF0		; Adresse lesen
		rcall	ds1820_writebyte
		ldi		XL, low(ds1820_id_ad)
		ldi		XH, high(ds1820_id_ad) ; X: Anfang SRAM
		ldi 	count,8			; 8 Bytes lesen
sid_1:	push 	count			; Anfang äußere Schleife
		ldi 	temp,1
		mov		mask,temp
		clr 	value
		ldi		count, 8		; 8 Bits lesen
sid_2:	ldi 	wait,40			; Anfang innere Schleife
		rcall 	ds1820_wait
		rcall 	ds1820_readbit		; Bit nach <temp> einlesen
		sbrc	temp, 0			; Falls 1
		add		value, mask		; 	...value=value+mask
		push 	temp
		mov		tmp, temp
		lsl 	tmp
		push 	tmp
		rcall 	ds1820_readbit		; Komplement-Bit einlesen
		pop 	tmp
		add		temp, tmp		; temp = (Bit1 << 1) + Bit2
		cpi 	temp, 0			; (eigentlich sollte das unnötig sein)
		brne	sid_3			; == 0?
		ldi		error, 2		; Fehlercode 2 (>1 Sensor)
sid_3:	cpi 	temp,3			; == 3?
		brne	sid_4
		ldi		error, 3		; Fehlercode 3 (Bitfehler)
sid_4:	pop		temp
		rcall	ds1820_writebit
		lsl		mask
		dec		count
		brne	sid_2			; Ende innere Schleife
	
		mov 	temp, value
		st		X+, temp		; Wert abspeichern
;		rcall	OUTH
;		ldi		temp, ' '
;		rcall	OUTCH
		pop 	count
		dec 	count
		brne	sid_1			; Ende äußere Schleife
	
		cpi		error,0			; Kein Fehler?
		breq	sid_7			; 	...dann weiter
		rcall	PRI_ER
	
sid_7:	ret

ds1820_messen:
;cbr		flags,(1<<seco_f)
		rcall	ds1820_ausloesen
		cpi		error, 0
		breq	mess_0		; keine Fehlermeldung?
		ret					;	dann weiter
mess_0:	ldi		ZH,0x02;0x02		; 750 ms warten
		ldi		ZL,0xEE
		rcall	ds1820_waitms		; 
		nop	     		;sbi	, DSPWR
		rcall	ds1820_auslesen
		rcall	DS1820_SEND_DATA
		ret
	
;------------------------------------------


