; void rtc_int_en(bit);
;
; Arguments
; - bit		: bit where interrupt enabled
;
; Return value
; - none
rtc_int_en:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | bit
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax

	; main part
	outp	0x70,0x0b		; select register B
	in	al,0x71			; read data
	or	al,[ebp+8]		; enable specified bit
	out	0x71,al			; write data

	; restore registers
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

; int_rtc : interuption for rtc
int_rtc:
	; save registers
	pusha
	push	ds
	push	es

	; set segments
	mov	ax,0x0010
	mov	ds,ax
	mov	es,ax

	; get time from RTC
	cdecl	rtc_get_time,RTC_TIME

	; get source of interrupt
	outp	0x70,0x0c		; select register C
	in	al,0x71			; read data

	; send EOI
	outp	0xa0,0x20
	outp	0x20,0x20

	; restore registers
	pop	es
	pop	ds
	popa

	iret
