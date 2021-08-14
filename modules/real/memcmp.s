; WORD memcmp(src0, src1, size);
;
; Arguments
; - src0	: source address 0
; - src1	: source address 1
; - size	: byte size to compare
;
; Return value
; - 0		: match
; - not 0	: not match

memcmp:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; ------|------
	; BP+ 4 | src0
	; BP+ 6 | src1
	; BP+ 8 | size
	push	bp
	mov	bp,sp

	; save registers
	push	cx
	push	si
	push	di

	; get arguments
	cld			; DF = 0 (forward direction)
	mov	si,[bp+4]	; SI = source address 0
	mov	di,[bp+6]	; DI = source address 1
	mov	cx,[bp+8]	; CX = byte size to compare

	; compare
	repe	cmpsb		; while (CX-- != 0 && ZF == 0) cmp(*SI++, *DI++);

	jnz	.10F
	mov	ax,0		; if (ZF == 0) AX = 0;
	jmp	.10E
.10F:
	mov	ax,-1		; if (ZF != 0) AX = 0;
.10E:

	; restore registers
	pop	di
	pop	si
	pop	cx

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret
