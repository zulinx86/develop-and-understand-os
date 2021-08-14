;************************************************************************
; First Sector Which BIOS Loads
;************************************************************************
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
	mov	ds,ax			; ds = 0x0000
	mov	es,ax			; es = 0x0000
	mov	ss,ax			; ss = 0x0000
	mov	sp,BOOT_LOAD		; sp = 0x7c00

	sti

	mov	[BOOT.DRIVE],dl		; save the boot drive number

	;-------------------------------
	; Display String
	;-------------------------------
	cdecl	puts,.s0


	;-------------------------------
	; Load Next 512 Bytes
	;-------------------------------
	mov	ah,0x02			; function to load
	mov	al,1			; number of sectors to load
	mov	cx,0x0002		; cylinder / sector
	mov	dh,0x00			; head
	mov	dl,[BOOT.DRIVE]		; drive number
	mov	bx,0x7c00+512		; offset
	int	0x13			; if (CF = BIOS(0x13,AH))
.10Q:	jnc	.10E			; {
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
.DRIVE:	dw	0		; boot drive number

	;-------------------------------
	; Modules
	;-------------------------------
%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"

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
	times	(1024*8)-($-$$) db 0
