;************************************************************************
; First Sector Which BIOS Loads
;************************************************************************
	
	;-------------------------------
	; Macros
	;-------------------------------
%include	"../include/define.s"
%include	"../include/macro.s"

	org	BOOT_LOAD

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
	mov	ds,ax			; ds = 0x0000
	mov	es,ax			; es = 0x0000
	mov	ss,ax			; ss = 0x0000
	mov	sp,BOOT_LOAD		; sp = 0x7c00

	sti

	mov	[BOOT+drive.no],dl	; save the boot drive number

	;-------------------------------
	; Display String
	;-------------------------------
	cdecl	puts,.s0

	;-------------------------------
	; Load Next 512 Bytes
	;-------------------------------
	mov	bx,BOOT_SECT-1		; BX = the number of sectors left
	mov	cx,BOOT_LOAD+SECT_SIZE	; CX = the next address to load
	cdecl	read_chs,BOOT,bx,cx

	cmp	ax,bx			; if (AX != BX)
.10Q:	jz	.10E			; {
.10T:	cdecl	puts,.e0		;   puts(.e0);
	call	reboot			;   reboot();
.10E:					; }

	;-------------------------------
	; Go To Stage 2
	;-------------------------------
	jmp	stage_2

	;-------------------------------
	; Data
	;-------------------------------
.s0	db	"Booting...",0x0a,0x0d,0
.e0	db	"Error: sector load",0

	align 2, db 0
BOOT:
	istruc drive
		at drive.no,	dw 0
		at drive.cyln,	dw 0
		at drive.head,	dw 0
		at drive.sect,	dw 2
	iend

	;-------------------------------
	; Modules
	;-------------------------------
%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"
%include	"../modules/real/read_chs.s"

	;-------------------------------
	; Boot Flag
	;-------------------------------
	times	510-($-$$) db 0x00
	db	0x55,0xaa


;************************************************************************
; Stage 2
;************************************************************************
stage_2:
	;-------------------------------
	; display string
	;-------------------------------
	cdecl	puts,.s0

	;-------------------------------
	; Loop
	;-------------------------------
	jmp	$

	;-------------------------------
	; Data
	;-------------------------------
.s0	db	"2nd stage...",0x0a,0x0d,0


	;-------------------------------
	; padding
	;-------------------------------
	times	(BOOT_SIZE)-($-$$) db 0

