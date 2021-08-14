; void itoa(num, buff, size, radix, flags);
;
; Arguments
; - num		: number
; - buff	: buffer address
; - size	: buffer size
; - radix	: radix (2, 8, 10, 16)
; - flags	: flags
; 		    B0 : 1 => signed value
;		         0 => unsigned value
; 		    B1 : 1 => display sign
; 		         0 => not display sign
; 		    B2 : 1 => fill with '0'
; 		         0 => fill with ' '
;
; Return value
; - none
itoa:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; ------|------
	; BP+ 4 | num
	; BP+ 6 | buff
	; BP+ 8 | size
	; BP+10 | radix
	; BP+12 | flags
	push	bp
	mov	bp,sp

	; store registers
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di


	; get arguments
	mov	ax,[bp+4]		; val = num
	mov	si,[bp+6]		; start = buf
	mov	cx,[bp+8]		; size = size

	mov	di,si
	add	di,cx
	dec	di			; end = &dst[size - 1]

	mov	bx,[bp+12]

	; check sign
	test	bx,0b0001		; if (flags & 0x01)
.10Q:	je	.10E			; {
	cmp	ax,0			;   if (val < 0)
.12Q:	jge	.12E			;   {
	or	bx,0b0010		;     flags != 2;
.12E:					;   }
.10E:					; }

	; display sign
	test	bx,0b0010		; if (flags & 0x02)
.20Q:	je	.20E			; {
	cmp	ax,0			;   if (val < 0)
.22Q:	jge	.22F			;   {
	neg	ax			;     val *= -1;
	mov	[si],byte '-'		;     *start = '-';
	jmp	.22E			;   }
.22F:					;   else
					;   {
	mov	[si],byte '+'		;     *start = '+';
.22E:					;   }
	dec	cx			;   size--;
.20E:					; }

	; convert to ASCII
	mov	bx,[bp+10]		; BX = radix
.30L:					; do
					; {
	mov	dx,0			;
	div	bx			;   DX = DX:AX % radix;
					;   AX = DX:AX / radix;
	mov	si,dx			;
	mov	dl,byte[.ascii+si]	;   DL = ASCII[DX];
					;
	mov	[di],dl			;   *end = DL;
	dec	di			;   end--;
					;
	cmp	ax,0			;
	loopnz	.30L			; } while (AX);
.30E:

	; fill blank
	cmp	cx,0			; if (size)
.40Q:	je	.40E			; {
	mov	al,' '			;   AL = ' ';
	cmp	[bp+12],word 0b0100	;   if (flags & 0x04)
.42Q:	jne	.42E			;   {
	mov	al,'0'			;     AL = '0';
.42E:					;   }
	std				;   DF = 1; (backward direction)
	rep	stosb			;   while (CX--) *DI-- = AL;
.40E:					; }

	; restore registers
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret

.ascii	db	"0123456789ABCDEF"
