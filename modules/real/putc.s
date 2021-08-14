; void putc(ch);
;
; Arguments
; - ch		: character code
;
; Return value
; - none

putc:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | ch
	push	bp
	mov	bp,sp

	; save registers
	push	ax
	push	bx

	; display a character
	mov	al,[bp+4]
	mov	ah,0x0e
	mov	bx,0x0000
	int	0x10

	; restore registers
	pop	bx
	pop	ax

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret
