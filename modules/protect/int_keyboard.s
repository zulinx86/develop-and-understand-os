; int_keyboard : interruption for keyboard
int_keyboard:
	; save registers
	pusha
	push	ds
	push	es

	; set data segments
	mov	ax,0x0010
	mov	ds,ax
	mov	es,ax

	; read KBC buffer
	in	al,0x60

	; save key code
	cdecl	ring_wr,_KEY_BUFF,eax

	; end of interruption
	outp	0x20,0x20

	; restore registers
	pop	es
	pop	ds
	popa

	iret

	align	4, db 0
_KEY_BUFF:
	times	ring_buff_size db 0
