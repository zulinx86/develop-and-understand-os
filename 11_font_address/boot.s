;************************************************************************
; First Sector Which BIOS Loads
;************************************************************************
	;-------------------------------
	; Macros
	;-------------------------------
%include "../include/define.s"
%include "../include/macro.s"

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
.s0:	db	"Booting...",0x0a,0x0d,0
.e0:	db	"Error: sector load",0

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
%include "../modules/real/puts.s"
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

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
	; Display String
	;-------------------------------
	cdecl	puts,.s0

	;-------------------------------
	; Get Drive Parameters
	;-------------------------------
	cdecl	get_drive_param,BOOT
	cmp	ax,0			; if (AX == 0)
.10Q:	jne	.10E			; {
.10T:	cdecl	puts,.e0		;   puts(.e0);
	call	reboot			;   reboot();
.10E:					; }

	;-------------------------------
	; Display Drive Parameters
	;-------------------------------
	mov	ax,[BOOT+drive.no]
	cdecl	itoa,ax,.p1,2,16,0b0100
	mov	ax,[BOOT+drive.cyln]
	cdecl	itoa,ax,.p2,4,16,0b0100
	mov	ax,[BOOT+drive.head]
	cdecl	itoa,ax,.p3,2,16,0b0100
	mov	ax,[BOOT+drive.sect]
	cdecl	itoa,ax,.p4,2,16,0b0100
	cdecl	puts,.s1

	;-------------------------------
	; Go To Stage 3
	;-------------------------------
	jmp	stage_3

	;-------------------------------
	; Data
	;-------------------------------
.s0:	db	"2nd stage...",0x0a,0x0d,0

.s1:	db	" Drive:0x"
.p1:	db	"  , C:0x"
.p2:	db	"    , H:0x"
.p3:	db	"  , S:0x"
.p4:	db	"  ",0x0a,0x0d,0

.e0	db	"Can't get drive parameter.",0

	;-------------------------------
	; Modules
	;-------------------------------
%include "../modules/real/itoa.s"
%include "../modules/real/get_drive_param.s"

;************************************************************************
; Stage 3
;************************************************************************
stage_3:	
	;-------------------------------
	; Display String
	;-------------------------------
	cdecl	puts,.s0

	;-------------------------------
	; Get Font Address
	;-------------------------------
	cdecl	get_font_addr,FONT

	;-------------------------------
	; Display Font Address
	;-------------------------------
	cdecl	itoa,word [FONT.seg],.p1,4,16,0b0100
	cdecl	itoa,word [FONT.off],.p2,4,16,0b0100
	cdecl	puts,.s1
	
	;-------------------------------
	; Loop
	;-------------------------------
	jmp	$

	;-------------------------------
	; Data
	;-------------------------------
.s0:	db	"3rd stage...",0x0a,0x0d,0
.s1:	db	" Font Address="
.p1:	db	"ZZZZ:"
.p2:	db	"ZZZZ",0x0a,0x0d,0

FONT:
.seg:	dw	0
.off:	dw	0

	;-------------------------------
	; Modules
	;-------------------------------
%include "../modules/real/get_font_addr.s"


	;-------------------------------
	; Zero Padding
	;-------------------------------
	times	(BOOT_SIZE)-($-$$) db 0
