; DWORD rtc_get_time(dst);
;
; Arguments
; - dst		: destination address
;
; Return value
; - 0		: fail
; - non 0	: success
rtc_get_time:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | dst
	push	ebp
	mov	ebp,esp

	; save registers
	push	ebx

	; main part
	mov	al,0x0a
	out	0x70,al
	in	al,0x71			; AL = register A;
	test	al,0x80			; if (AL & UIP) // now updating
	je	.10F			; {
	mov	eax,1			;   ret = 1;
	jmp	.10E			; }
.10F:					; else
					; {
	mov	al,0x04			;
	out	0x70,al			;
	in	al,0x71			;   AL = hour;
	shl	eax,8			;   EAX <<= 8;

	mov	al,0x02			;
	out	0x70,al			;
	in	al,0x71			;   AL = minute;
	shl	eax,8			;   EAX <<= 8;

	mov	al,0x00			;
	out	0x70,al			;
	in	al,0x71			;   AL = second;

	and	eax,0x00ffffff
	mov	ebx,[ebp+8]
	mov	[ebx],eax		;   [dst] = EAX;

	mov	eax,0			;   EAX = 0;
.10E:					; }

	; restore registers
	pop	ebx

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret
