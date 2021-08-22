; void draw_rect(x0, y0, x1, y1, color);
;
; Arguments
; - x0		: x of start point
; - y0		: y of start point
; - x1		: x of end point
; - y1		: y of end point
; - color	: color
;
; Return value
; - none
draw_rect:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | x0
	; EBP+12 | y0
	; EBP+16 | x1
	; EBP+20 | y1
	; EBP+24 | color
	push	ebp
	mov	ebp,esp

	; save registers

	; main part
	mov	eax,[ebp+8]
	mov	ebx,[ebp+12]
	mov	ecx,[ebp+16]
	mov	edx,[ebp+20]
	mov	esi,[ebp+24]

	cmp	eax,ecx			; if (x0 >= x1)
	jl	.10E			; {
	xchg	eax,ecx			;   EAX <-> ECX
.10E:					; }

	cmp	ebx,edx			; if (y0 >= y1)
	jl	.20E			; {
	xchg	ebx,edx			;   EBX <-> EDX
.20E:					; }

	cdecl	draw_line,eax,ebx,ecx,ebx,esi
	cdecl	draw_line,eax,ebx,eax,edx,esi

	dec	edx
	cdecl	draw_line,eax,edx,ecx,edx,esi
	inc	edx

	dec	ecx
	cdecl	draw_line,ecx,ebx,ecx,edx,esi

	; restore registers
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret
