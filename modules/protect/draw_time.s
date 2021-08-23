; void draw_time(col, row, color, time);
;
; Arguments
; - col		: column
; - row		: row
; - color	: color
; - time	: time
;
; Return value
; - none
draw_time:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | col
	; EBP+12 | row
	; EBP+16 | color
	; EBP+20 | time
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	ebx

	; main part
	mov	eax,[ebp+20]
	cmp	eax,[.last]		; if (*.last != EAX) // previous != current
	je	.10E			; {
	mov	[.last],eax		;   *.last = EAX;

	mov	ebx,0			;   // second
	mov	bl,al
	cdecl	itoa,ebx,.sec,2,16,0b0100

	mov	bl,ah			;   // minute
	cdecl	itoa,ebx,.min,2,16,0b0100

	shr	eax,16			;   // hour
	cdecl	itoa,eax,.hour,2,16,0b0100

	cdecl	draw_str,dword [ebp+8],dword [ebp+12],dword [ebp+16],.hour
.10E:					; }

	; restore registers
	pop	ebx
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

	align	2, db 0
.temp:	dq	0
.last:	dq	0
.hour:	db	"ZZ:"
.min:	db	"ZZ:"
.sec:	db	"ZZ",0
