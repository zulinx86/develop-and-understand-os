; void draw_line(x0, y0, x1, y1, color);
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
draw_line:
	; stack frame
	; EBP-28 | inc_y = 0;
	; EBP-24 | dy = 0;
	; EBP-20 | y = 0;
	; EBP-16 | inc_x = 0;
	; EBP-12 | dx = 0;
	; EBP- 8 | x = 0;
	; EBP- 4 | sum = 0;
	; -------|-------
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
	push	dword 0
	push	dword 0
	push	dword 0
	push	dword 0
	push	dword 0
	push	dword 0
	push	dword 0

	; save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	; main part
	mov	eax,[ebp+8]		; EAX = x0;
	mov	ebx,[ebp+16]		; EBX = x1;
	sub	ebx,eax			; EBX = x1 - x0;
	jge	.10F			; if (EBX < 0)
					; {
	neg	ebx			;   EBX *= -1;
	mov	esi,-1			;   ESI = -1;
	jmp	.10E			; }
.10F:					; else
					; {
	mov	esi,1			;   ESI = 1;
.10E:					; }

	mov	ecx,[ebp+12]		; ECX = y0;
	mov	edx,[ebp+20]		; EDX = y1;
	sub	edx,ecx			; EDX = y1 - y0;
	jge	.20F			; if (EDX < 0)
					; {
	neg	edx			;   EDX *= -1;
	mov	edi,-1			;   EDI = -1;
	jmp	.20E			; {
.20F:					; else
					; {
	mov	edi,1			;   EDI = 1;
.20E:					; }

	mov	[ebp-8],eax		; x = x0;
	mov	[ebp-12],ebx		; dx = abs(x1 - x0);
	mov	[ebp-16],esi		; inc_x = ESI;

	mov	[ebp-20],ecx		; y = y0;
	mov	[ebp-24],edx		; dy = abs(y1 - y0);
	mov	[ebp-28],edi		; inc_y = EDI;

	cmp	ebx,edx			; if (dx <= dy)
	jg	.22F			; {
	lea	esi,[ebp-20]		;   ESI = &y0;
	lea	edi,[ebp-8]		;   EDI = &x0;
					; }
	jmp	.22E			; else
.22F:					; {
	lea	esi,[ebp-8]		;   ESI = &x0;
	lea	edi,[ebp-20]		;   EDI = &y0;
.22E:					; }

	mov	ecx,[esi-4]		; ECX = *(ESI-4); // dx or dy
	cmp	ecx,0			; if (ECX == 0)
	jnz	.30E			; {
	mov	ecx,1			;   ECX = 1;
.30E:					; }

.50L:					; do
					; {
	cdecl	draw_pixel, \
			dword [ebp-8], \
			dword [ebp-20], \
			dword [ebp+24]
	
	mov	eax,[esi-8]		;
	add	[esi-0],eax		;   *(ESI-0) += *(ESI-8); // x += inc_x; or y += inc_y;

	mov	eax,[ebp-4]		;
	add	eax,[edi-4]		;   EAX = sum + *(EDI-4); // dx or dy
	mov	ebx,[esi-4]		;   EBX = *(ESI-4); // dy or dx
	cmp	eax,ebx			;   if (EAX >= EBX)
	jl	.52E			;   {
	sub	eax,ebx			;     EAX -= EBX;
	mov	ebx,[edi-8]		;
	add	[edi-0],ebx		;     *(EDI-0) += *(EDI-8); // y += inc_y; or x += inc_x;
.52E:					;   }
	mov	[ebp-4],eax		;   sum = EAX;
	loop	.50L			;
.50E:					; } while (--ECX);

	; restore registers
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

