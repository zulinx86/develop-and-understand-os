; void memcpy(dst, src, size);
;
; Arguments
; - dst		: destination address
; - src		: source address
; - size	: byte size to copy
; 
; Return value
; - none

memcpy:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; ------|------
	; BP+ 4 | dst
	; BP+ 6 | src
	; BP+ 8 | size
	push	bp
	mov	bp,sp

	; save registers
	push	cx
	push	si
	push	di

	; copy
	cld			; DF = 0 (forward direction);
	mov	di,[bp+4]	; DI = destination address
	mov	si,[bp+6]	; SI = source address
	mov	cx,[bp+8]	; CX = byte size to copy
	rep	movsb		; while (CX-- != 0) *DI++ = *SI++;

	; restore registers
	pop	di
	pop	si
	pop	cx

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret
