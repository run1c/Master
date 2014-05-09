;
;******************************************************************
;*
;* Basic routines for communicating with the on Chip UART
;* and data format conversion
;*
;***************************************************************** 
;
;--------------------------------------------------
; hex-print byte in temp --> ASCII --> OUT UART
; This funtion must be directly followed by OUTCH.
;
;--------------------------------------------------

OUTH:	push	temp
		swap	temp              ; high nibble
        rcall   OUTHR
	    pop		temp               ; low  nibble
OUTHR:  andi    temp,0x0F          ; mask nibble
		ldi		tmp,0x30
	    add     temp,tmp           ; make ascii
        cpi		temp,0x3A          ; digit ?
	
        brlo    OUTCH
        ldi		tmp,0x07
		add		temp,tmp           ; A..F
;  
;---------------------------------------------------------
; OUT one ASCII to UART
;---------------------------------------------------------
;
OUTCH:	lds		tmp,UCSR0A
		sbrs	tmp,udre0
		rjmp	OUTCH
		sbi		ENA_PORT,ENA_PIN
		ldi		wait,0x18;0x0A ;0x07
		rcall	waitus

	ldi	tmp,0x48		; 0x18 Txena,Rxena; 0x58 Txena, TxIena, Rxena
	sts	UCSR0B,tmp
		sts		UDR0,temp
		ret
		
;  
;---------------------------------------------------------
; decimal print byte in temp --> ASCII --> OUT UART
;---------------------------------------------------------
OUTD3:
OUTD:		ldi 	tmp, 100
		rcall	print_dec_digit
OUTD2:	ldi 	tmp, 10
		rcall	print_dec_digit
OUTD1:	ldi 	tmp, 1
		rcall	print_dec_digit
		ret
; 
print_dec_digit:
		clr	count
pdd_0:	inc 	count
		sub 	temp, tmp
		brcc	pdd_0
		dec 	count
		add		temp, tmp
		push 	temp
		ldi		temp, '0'
		add		temp, count
		rcall	OUTCH
		pop		temp
		ret	
;***************************************************************************
;*
;* "bin2BCD16" - 16-bit Binary to BCD conversion
;*
;* This subroutine converts a 16-bit number (fbinH:fbinL) to a 5-digit 
;* packed BCD number represented by 3 bytes (tBCD2:tBCD1:tBCD0).
;* MSD of the 5-digit number is placed in the lowermost nibble of tBCD2.
;*  
;* Number of words	:25
;* Number of cycles	:751/768 (Min/Max)
;* Low registers used	:3 (tBCD0,tBCD1,tBCD2) 
;* High registers used  :4(fbinL,fbinH,cnt16a,tmp16a)	
;* Pointers used	:Z
;*
;***************************************************************************
;
;*****"bin2BCD16" - 16-bit Binary to BCD conversion Subroutine Register Variables

;.equ	AtBCD0	=13		;address of tBCD0
;.equ	AtBCD2	=15		;address of tBCD1

;.def	tBCD0	=r13		;BCD value digits 1 and 0
;.def	tBCD1	=r14		;BCD value digits 3 and 2
;.def	tBCD2	=r15		;BCD value digit 4
;.def	fbinL	=r16		;binary value Low byte
;.def	fbinH	=r17		;binary value High byte
;.def	cnt16a	=r18		;loop counter
;.def	temp	=r19		;temporary value
;**************************************************************************
;***** Code

bin2BCD16:
	ldi		temp,16		;Init loop counter
	mov		count,temp	
	clr		tBCD2		;clear result (3 bytes)
	clr		tBCD1		
	clr		tBCD0		
	clr		ZH			;clear ZH (not needed for AT90Sxx0x)
bBCDx_1:
	lsl		fbinL		;shift input value
	rol		fbinH		;through all bytes
	rol		tBCD0		;
	rol		tBCD1
	rol		tBCD2
	dec		count		;decrement loop counter
	brne	bBCDx_2		;if counter not zero
	ret					; return

bBCDx_2:
	ldi		r30,AtBCD2+1	;Z points to result MSB + 1
bBCDx_3:
	ld		temp,-Z		;get (Z) with pre-decrement
	subi	temp,-$03	;add 0x03
	sbrc	temp,3		;if bit 3 not clear
	st		Z,temp		;store back
	ld		temp,Z		;get (Z)
	subi	temp,-$30	;add 0x30
	sbrc	temp,7		;if bit 7 not clear
	st		Z,temp		;store back
	cpi		ZL,AtBCD0	;done all three?
	brne	bBCDx_3		;loop again if not
	rjmp	bBCDx_1			

;---------------------------------------------------------
; read character, echo, convert to upper ASCII -> temp
;---------------------------------------------------------
INCHE:	lds		tmp,UCSR0A
		sbrs	tmp,rxc0
		rjmp	INCHE
;in		temp,UDR
		lds		temp,UDR0
		rcall	OUTCH		; ECHO
		cpi		temp,'a'
		brlt	INE_R
		subi	temp,' '	; --> upper
INE_R:	ret

;---------------------------------------------------------
; read character,no echo, convert to upper ASCII -> temp
;---------------------------------------------------------
INCH:	lds		tmp,UCSR0A
		sbrs	tmp,rxc0
		rjmp	INCH
		lds		temp,UDR0		
;		in		temp,UDR
		cpi		temp,'a'
		brlt	IN_R
		subi	temp,' '	; --> upper
IN_R:	ret
;
;
;INCH_P:	lds		temp,UCSR0A
;		sbrs	temp,RXC0
;		rjmp	IS_UP
;		lds		temp,UDR0
;		cpi		temp,'a'
;		brlt	IS_UP
;		subi	temp,' '	; --> upper
;IS_UP:	ret



;------------------------------------------------------------
; get ASCII --> one HEX value  --> temp  ( upper case only )
;------------------------------------------------------------
INHEX:	rcall	INCH		; get char
HEX_N:	cpi		temp,13	; CR	?
		breq	HEX_RET_1
		subi	temp,0x30	; ascii --> hex
		brmi	HEX_E   	;
		cpi		temp,0x0A	; digit ?
		brmi	HEX_R		; yes
		cpi		temp,0x11	; < A ?
		brmi	HEX_E  		; yes, error
		cpi		temp,0x17	; > F ?
		brmi	HEX_S		; yes, error
HEX_E:	rjmp	HEX_RET_0      	; wait for hex number
;
HEX_S:	subi	temp,0x07	; 0A...0F
HEX_R:
		push	temp		; save
		rcall	OUTHR		; ECHO only hex value
		pop		temp		; recall hex value

HEX_RET_0:
		clc
		ret
HEX_RET_1:
		sec
		ret
;
;
;-----------------------------------------------------------
; get BYTE ASCII --> ( hex ) --> temp
;-----------------------------------------------------------
BYTE:		rcall   INHEX		; high nibble
BYTE_L:		swap	temp
		push	temp	; save high nibble
		rcall   INHEX		; low nibble
		pop	tmp
		add	temp,tmp	; high + low
		ret
;
;-----------------------------------------------------------
; print page asciz-string via Z-pointer
;-----------------------------------------------------------

PRIP_L:		rcall   OUTCH		; out
PRINTP:		lpm			; r0 <- (Z)  get char.
		adiw	ZL,1		; inc Z pointer
		mov	temp,r0
		cpi	temp,10
		brne	PRIP1
		inc	tmp
		cpi	tmp,0x10
		brlo	PRIP1
		push	temp
		clr	tmp
		rcall	INCH
		pop	temp
PRIP1:		cpi	temp,0x00
		brne    PRIP_L		; 0 == end string
		ret
;
;-----------------------------------------------------------
; print asciz-string via Z-pointer
;-----------------------------------------------------------
;
PRI_L:		rcall   OUTCH		; out
PRINT:		lpm			; r0 <- (Z)  get char.
		adiw	ZL,1		; inc Z pointer
		mov	temp,r0
		cpi	temp,0x00
		brne    PRI_L		; 0 == end string
		ret
;
PRI_AUX:ldi	ZL,low(AUXPMT*2)
	ldi	ZH,high(AUXPMT*2)
	rcall	PRINT
	ret	


;PRI_ERR:ldi	ZL,low(ERR_TX*2)
;	ldi	ZH,high(ERR_TX*2)
;	rcall	PRINT
;	ldi	temp, '0'
;	add	temp, error
;	rcall	OUTCH
;	ret	
	
PRI_ER:	ldi		ZL,low(ERR_TX*2)
		ldi		ZH,high(ERR_TX*2)
		rcall	PRINT
		ret	

HELP:	ldi	ZL,low(HELP_TX*2)
	ldi	ZH,high(HELP_TX*2)
	clr	tmp
	rcall	PRINT
	ret

;********************************************************
;* waitus: Warten von wenigen Mikrosekunden	*
;* Wartezeit: (wait + 2)us				*
;* Achtung: 1 Zyklus wird für den 'ldi' Befehl		*
;*          _vor_ dem Aufruf gebraucht!			*
;********************************************************

waitus: 				; 3
	lsl		wait		; x2 for 8MHz CPU
waitus_1:
	dec 	wait		; 1
	nop					; 1
	brne 	waitus_1	; 2 (1)
	nop					; 1
	ret					; 4

;**** End of File ****
