; void draw_rotation_bar(void);
;
; Arguments
; - none
;
; Return value
; - none
draw_rotation_bar:
	; save registers
	push	eax

	mov	eax,[TIMER_COUNT]
	shr	eax,4
	cmp	eax,[.index]
	je	.10E

	mov	[.index],eax
	and	eax,0x03

	mov	al,[.table+eax]
	cdecl	draw_char,0,29,0x000f,eax

.10E:

	; restore registers
	pop	eax

	ret

	align	4, db 0
.index:	dd	0
.table:	dd	"|/-\"
