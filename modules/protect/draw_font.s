; void draw_font(col, row);
;
; Arguments
; - col		: column
; - row		: row
;
; Return value
; - none
draw_font:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | column
	; EBP+12 | row
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	ebx
	push	ecx
	push	esi
	push	edi

	; main part
	mov	esi,[ebp+8]
	mov	edi,[ebp+12]

	mov	ecx,0			; for (ECX = 0;
.10L:	cmp	ecx,256			;      ECX < 256
	jae	.10E			;
					;      ECX++)
					; {
	mov	eax,ecx			;
	and	eax,0x0f		;
	add	eax,esi			;   EAX = column;

	mov	ebx,ecx			;
	shr	ebx,4			;
	add	ebx,edi			;   EBX = row;

	cdecl	draw_char,eax,ebx,0x07,ecx

	inc	ecx
	jmp	.10L
.10E:

	; restore registers
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret
