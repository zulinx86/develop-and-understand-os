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
	; Display String
	;-------------------------------
	cdecl	puts,.s0


	;-------------------------------
	; Display Numbers
	;-------------------------------
	cdecl	itoa,8086,.s1,8,10,0b0001
	cdecl	puts,.s1

	cdecl	itoa,8086,.s1,8,10,0b0011
	cdecl	puts,.s1

	cdecl	itoa,-8086,.s1,8,10,0b0001
	cdecl	puts,.s1
	
	cdecl	itoa,-1,.s1,8,10,0b0001
	cdecl	puts,.s1

	cdecl	itoa,-1,.s1,8,10,0b0000
	cdecl	puts,.s1

	cdecl	itoa,-1,.s1,8,16,0b0000
	cdecl	puts,.s1

	cdecl	itoa,12,.s1,8,2,0b0100
	cdecl	puts,.s1

	jmp	$


	;-------------------------------
	; Data
	;-------------------------------
.s0	db	"Booting...",0x0a,0x0d,0
.s1	db	"--------",0x0a,0x0d,0

	align 2, db 0
BOOT:
.DRIVE:	dw	0		; boot drive number

	;-------------------------------
	; Modules
	;-------------------------------
%include	"../modules/real/puts.s"
%include	"../modules/real/itoa.s"

	;-------------------------------
	; Boot Flag
	;-------------------------------
	times	510-($-$$) db 0x00
	db	0x55,0xaa
