; void draw_color_bar(col, row);
;
; Arguments
; - col		: column
; - row		: row
;
; Return value
; - none
draw_color_bar:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | col
	; EBP+12 | row
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	; main part
	mov	esi,[ebp+8]
	mov	edi,[ebp+12]

	mov	ecx,0
.10L:	cmp	ecx,16
	jae	.10E

	mov	eax,ecx
	and	eax,0x01
	shl	eax,3
	add	eax,esi			; column

	mov	ebx,ecx
	shr	ebx,1
	add	ebx,edi			; row

	mov	edx,ecx
	shl	edx,1
	mov	edx,[.t0+edx]		; color

	cdecl	draw_str,eax,ebx,edx,.s0

	inc	ecx
	jmp	.10L
.10E:

	; restore registers
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; delete stack
	mov	esp,ebp
	pop	ebp
	
	ret

.s0:	db	'        ',0
.t0:	dw	0x0000,0x0800
	dw	0x0100,0x0900
	dw	0x0200,0x0a00
	dw	0x0300,0x0b00
	dw	0x0400,0x0c00
	dw	0x0500,0x0d00
	dw	0x0600,0x0e00
	dw	0x0700,0x0f00
