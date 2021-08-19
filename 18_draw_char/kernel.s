;************************************************************************
; Kernel
;************************************************************************

	;-------------------------------
	; Macros
	;-------------------------------
%include "../include/define.s"
%include "../include/macro.s"

	org	KERNEL_LOAD

[BITS 32]
kernel:
	;-------------------------------
	; Get Font Address
	;-------------------------------
	mov	esi,BOOT_LOAD+SECT_SIZE	; ESI = 0x7c00 + 512;
	movzx	eax,word [esi+0]	; EAX = [ESI+0]; // FONT.seg
	movzx	ebx,word [esi+2]	; EBX = [ESI+2]; // FONT.off
	shl	eax,4			; EAX <<= 4;
	add	eax,ebx			; EAX += EBX;
	mov	[FONT_ADDR],eax		; FONT_ADDR[0] = EAX;

	;-------------------------------
	; Display A Character
	;-------------------------------
	cdecl	draw_char,0,0,0x010F,'A'
	cdecl	draw_char,1,0,0x010F,'B'
	cdecl	draw_char,2,0,0x010F,'C'

	cdecl	draw_char,0,0,0x0402,'0'
	cdecl	draw_char,1,0,0x0212,'1'
	cdecl	draw_char,2,0,0x0212,'_'

	;-------------------------------
	; Loop
	;-------------------------------
	jmp	$

	;-------------------------------
	; Data
	;-------------------------------
	align	4, db 0
FONT_ADDR:
	dd	0

	;-------------------------------
	; Modules
	;-------------------------------
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"

	;-------------------------------
	; Padding
	;-------------------------------
	times	KERNEL_SIZE-($-$$) db 0x00
