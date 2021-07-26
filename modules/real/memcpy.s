; function prototype
; 	void memcpy(dst, src, size);
;
; arguments
; 	dst		: destination address
; 	src		: source address
; 	size	: byte size to copy
;
; return value
; 	none

memcpy:
		; create stack frame
		push	bp
		mov		bp,sp

		; save registers
		push	cx
		push	si
		push	di

		; copy
		cld					; DF = 0;
		mov		di,[bp+4]	; DI = destination address
		mov		si,[bp+6]	; SI = source address
		mov		cx,[bp+8]	; CX = byte size to copy
		rep		movsb

		; restore registers
		pop		di
		pop		si
		pop		cx

		; delete stack frame
		mov		sp,bp
		pop		bp

		ret
