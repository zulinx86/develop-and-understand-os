; function prototype
; 	WORD memcmp(src0, src1, size);
;
; arguments
; 	src0	: source address 0
; 	src1	: source address 1
;	size	: byte size to compare
;
; return value
;	0		: match
;	1		: not match

memcmp:
		; create stack frame
		push	bp
		mov		bp,sp

		; save registers
		push	cx
		push	si
		push	di

		; get arguments
		cld					; DF = 0
		mov		si,[bp+4]	; SI = source address 0
		mov		di,[bp+6]	; DI = source address 1
		mov		cx,[bp+8]	; CX = byte size to compare

		; compare
		repe	cmpsb
		jnz		.10F
		mov		ax,0
		jmp		.10E
.10F:
		mov		ax,-1
.10E:

		; restore registers
		pop		di
		pop		si
		pop		cx

		; delete stack frame
		mov		sp,bp
		pop		bp

		ret
