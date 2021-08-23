; void itoa(num, buff, size, radix, flags);
;
; Arguments
; - num		: number
; - buff	: buffer
; - size	: size of buffer
; - radix	: radix
; - flags	: flags
; 		  - B2 : padding
; 			1 => zero padding
;			0 => space padding
;		  - B1 : display sign or not
;			1 => display sign
;			0 => not display sign
;		  - B0 : sign
;			1 => signed value
;			0 => unsigned value
;
; Return value
; - none
itoa:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | num
	; EBP+12 | buff
	; EBP+16 | size
	; EBP+20 | radix
	; EBP+24 | flags
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	; set arguments
	mov	eax,[ebp+8]		; EAX = num;
	mov	esi,[ebp+12]		; ESI = buff;
	mov	ecx,[ebp+16]		; ECX = size;

	mov	edi,esi
	add	edi,ecx			;
	dec	edi			; EDI = &buff[size - 1];

	mov	ebx,[ebp+24]

	; check if num is signed or unsigned
	test	ebx,0b0001
.10Q:	je	.10E
	cmp	eax,0
.12Q:	jge	.12E
	or	ebx,0b0010
.12E:
.10E:

	; check if sign is displayed or not
	test	ebx,0b0010
.20Q:	je	.20E
	cmp	eax,0
.22Q:	jge	.22F
	neg	eax
	mov	[esi],byte '-'
	jmp	.22E
.22F:
	mov	[esi],byte '+'
.22E:
	dec	ecx
.20E:

	; convert to ASCII
	mov	ebx,[ebp+20]		; EBX = radix;
.30L:					; do
					; {
	mov	edx,0			;   EDX = 0;
	div	ebx			;   DX = DX:AX % radix; AX = DX:AX / radix;

	mov	esi,edx			;   ESI = EDX;
	mov	dl,byte [.ascii+esi]	;   DL = *(.ascii+ESI);
	mov	[edi],dl		;   *(EDI) = DL;
	dec	edi			;   --EDI;

	cmp	eax,0			;
	loopnz	.30L			; } while (EAX);
.30E:

	; padding
	cmp	ecx,0			; if (size)
.40Q:	je	.40E			; {
	mov	al,' '			;   AL = ' ';
	cmp	[ebp+24],word 0b0100	;   if (flags & 0x04)
.42Q:	jne	.42E			;   {
	mov	al,'0'			;     AL = '0';
.42E:					;   }
	std				;   // backward direction
	rep	stosb			;   while (--ECX) *DI-- = AL;
.40E:					; }

	; restore registers
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

.ascii:	db	"0123456789ABCDEF"

