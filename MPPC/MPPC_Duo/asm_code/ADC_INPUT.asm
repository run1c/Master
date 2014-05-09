ADC_INPUT:
		cbr 		flags,(1<<hsec_f)
		mov		temp,samp_co
		andi		temp,0x03
		lsl		temp			; x2
		ldi		ZL,low(ad_res_l0)
		ldi		ZH,high(ad_res_l0)			; RAM address
		add		ZL,temp
		clr		temp
		adc		ZH,temp
		ld		adc_lres,Z+
		ld		adc_hres,Z
WAI_ADC:
		lds		temp,ADCSRA
		sbrs	temp,ADIF
		rjmp	WAI_ADC
		lds		temp,adcl
		add		adc_lres,temp
		lds		temp,adch
		adc		adc_hres,temp
		st		 Z,adc_hres
		st		-Z,adc_lres

		inc		samp_co

		mov		temp,samp_co
		andi	temp,0x03
		ori		temp,0xc0
		sts		ADMUX,temp		;Intern REF ENA/Ch no
		ldi		temp,0xd6
		sts		ADCSRA,temp		;start ADC
	mov		temp,samp_co
	andi	temp,0x0F		
	cpi		temp,0x0C
	brlo	measure_ret

calc_value:
		lsr		adc_hres		; :2
		ror		adc_lres
		lsr		adc_hres		; :2
		ror		adc_lres
;		lsr		adc_hres		; :2
;		ror		adc_lres
	cpi		temp,0x0D
	breq	calc_value_1
calc_value_end:
		std		Z+0x11,adc_hres
		std		Z+0x10,adc_lres
		clr		temp
		st		Z,temp
		std		Z+1,temp
		ret
; calibrate temperature
calc_value_1:		
		lds		temp,Tho	;0x5a
		add		adc_lres,temp
		ldi		temp,0x00
		adc		adc_hres,temp

		std		Z+0x11,adc_hres
		std		Z+0x10,adc_lres
		clr		temp
		st		Z,temp
		std		Z+1,temp

measure_ret:
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
