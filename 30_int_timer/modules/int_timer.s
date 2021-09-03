; int_timer : interruption for timer
int_timer:
	; save registers
	pusha
	push	ds
	push	es

	; set up data segments
	mov	ax,0x0010
	mov	ds,ax
	mov	es,ax

	; tick
	inc	dword [TIMER_COUNT]

	; EOI
	outp	0x20,0x20

	; restore registers
	pop	es
	pop	ds
	popa

	iret

	align	4, db 0
TIMER_COUNT:
	dd	0
