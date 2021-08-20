; void draw_str(col, row, color, p);
;
; Arguments
; - col		: column
; - row		: row
; - color	: color
; - p		: address to string
;
; Return value
; - none
draw_str:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | col
	; EBP+12 | row
	; EBP+16 | color
	; EBP+20 | p
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi

	; main part
	mov	ecx,[ebp+8]
	mov	edx,[ebp+12]
	movzx	ebx,word [ebp+16]
	mov	esi,[ebp+20]

	cld				; // forward direction
.10L:					; do
					; {
	lodsb				;   AL = *ESI++;
	cmp	al,0			;   if (AL == 0)
	je	.10E			;     break;

	cdecl	draw_char,ecx,edx,ebx,eax

	inc	ecx			;   ECX++;
	cmp	ecx,80			;   if (ECX >= 80)
	jl	.12E			;   {
	mov	ecx,0			;     ECX = 0;
	inc	edx			;     EDX++;
	cmp	edx,30			;     if (EDX >= 30)
	jl	.12E			;     {
	mov	edx,0			;        EDX = 0;
					;     }
.12E:					;   }
	jmp	.10L			; } while (1);
.10E:

	; restore registers
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; delete stack
	mov	esp,ebp
	pop	ebp

	ret
