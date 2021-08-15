; void get_font_addr(addr);
;
; Arguments
; - addr	: address to save the address of BIOS font
;
; Return value
; - none
get_font_addr:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | addr
	push	bp
	mov	bp,sp

	; save registers
	push	ax
	push	bx
	push	si
	push	es
	push	bp

	; main part
	mov	si,[bp+4]		; SI = addr;

	mov	ax,0x1130		; function to get font address
	mov	bh,0x06			; 8x16 font
	int	0x10			; ES:BP = font address

	mov	[si+0],es
	mov	[si+2],bp

	; restore registers
	pop	bp
	pop	es
	pop	si
	pop	bx
	pop	ax

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret
