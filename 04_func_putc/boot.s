	BOOT_LOAD	equ	0x7c00

	org	BOOT_LOAD
	
	;-------------------------------
	; Macros
	;-------------------------------
%include	"../include/macro.s"

entry:
	;-------------------------------
	; BPB (BIOS Parameter Block)
	;-------------------------------
	jmp	ipl
	times	90-($-$$) db 0x90

	;-------------------------------
	; IPL (Initial Program Loader)
	;-------------------------------
ipl:
	cli

	mov	ax,0x0000
	mov	ds,ax		; ds = 0x0000
	mov	es,ax		; es = 0x0000
	mov	ss,ax		; ss = 0x0000
	mov	sp,BOOT_LOAD	; sp = 0x7c00

	sti

	mov	[BOOT.DRIVE],dl	; save the boot drive number

	;-------------------------------
	; Display Characters
	;-------------------------------
	cdecl	putc, word 'X'
	cdecl	putc, word 'Y'
	cdecl	putc, word 'Z'

	jmp	$


	;-------------------------------
	; Boot Drive Info
	;-------------------------------
	align 2, db 0
BOOT:
.DRIVE:	dw	0		; boot drive number


	;-------------------------------
	; Modules
	;-------------------------------
%include	"../modules/real/putc.s"

	;-------------------------------
	; Boot Flag
	;-------------------------------
	times	510-($-$$) db 0x00
	db	0x55,0xaa
