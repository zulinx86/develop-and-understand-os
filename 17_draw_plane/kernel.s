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
	mov	esi,BOOT_LOAD+SECT_SIZE
	movzx	eax,word [esi+0]	; FONT.seg
	movzx	ebx,word [esi+2]	; FONT.off
	shl	eax,4
	add	eax,ebx
	mov	[FONT_ADDR],eax

	;-------------------------------
	; Draw Line
	;-------------------------------
	mov	ah,0x07			; 0b0111 (RGB)
	mov	al,0x02			; Select Write Plane
	mov	dx,0x03C4		; Sequencer Address Register
	out	dx,ax
	mov	[0x000a_0000+0],byte 0xff

	mov	ah,0x04			; 0b0100 (R)
	out	dx,ax
	mov	[0x000a_0000+1],byte 0xff

	mov	ah,0x02			; 0b0010 (G)
	out	dx,ax
	mov	[0x000a_0000+2],byte 0xff

	mov	ah,0x01			; 0b0001 (B)
	out	dx,ax
	mov	[0x000a_0000+3],byte 0xff

	mov	ah,0x07			; 0b0111 (RGB)
	out	dx,ax
	lea	edi,[0x000a_0000+80]
	mov	ecx,80
	mov	al,0xff
	rep	stosb			; while (--CX) *EDI++ = AL;

	;-------------------------------
	; Draw Rectangle
	;-------------------------------
	mov	edi,1
	shl	edi,8
	lea	edi,[edi*4+edi+0x000a_0000]

	mov	[edi+(80*0)],word 0xff
	mov	[edi+(80*1)],word 0xff
	mov	[edi+(80*2)],word 0xff
	mov	[edi+(80*3)],word 0xff
	mov	[edi+(80*4)],word 0xff
	mov	[edi+(80*5)],word 0xff
	mov	[edi+(80*6)],word 0xff
	mov	[edi+(80*7)],word 0xff

	;-------------------------------
	; Draw Character
	;-------------------------------
	mov	esi,'A'
	shl	esi,4
	add	esi,[FONT_ADDR]

	mov	edi,2
	shl	edi,8
	lea	edi,[edi*4+edi+0x000a_0000]

	mov	ecx,16			; ECX = 16
.10L:					; do
					; {
	movsb				;   *EDI++ = *ESI++;
	add	edi,80-1		;   EDI += 79;
	loop	.10L			; } while (--ECX);

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
	; Padding
	;-------------------------------
	times	KERNEL_SIZE-($-$$) db 0x00
