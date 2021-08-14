; void puts(str);
; 
; Arguments:
; - str		: address of string
; 
; Return value:
; - none
puts:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | str
	push	bp
	mov	bp,sp

	; save registers
	push	ax
	push	bx
	push	si

	; main part
	mov	si,[bp+4]
	mov	ah,0x0e		; function to display a character
	mov	bx,0x0000	; page number and color
	cld			; forward direction
.10L
	lodsb			; AL = *SI++;

	cmp	al,0
	je	.10E

	int	0x10
	jmp	.10L
.10E

	; restore registers
	pop	si
	pop	bx
	pop	ax

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret
