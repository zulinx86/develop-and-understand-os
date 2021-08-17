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
	cdecl	itoa,word [FONT.seg],.p1,4,16,0b0100
	cdecl	itoa,word [FONT.off],.p2,4,16,0b0100
	cdecl	puts,.s1
	
	;-------------------------------
	; Get Memory Info
	;-------------------------------
	cdecl	get_mem_info		; get_mem_info();

	mov	eax,[ACPI_DATA.addr]	; EAX = ACPI_DATA.addr;
	cmp	eax,0			; if (EAX)
	je	.10E			; {
	cdecl	itoa,ax,.p4,4,16,0b0100	;   itoa(AX);
	shr	eax,16			;   EAX >>= 16;
	cdecl	itoa,ax,.p3,4,16,0b0100	;   itoa(AX);
	cdecl	puts,.s2		;   puts(.s2); 
.10E:					; }

	;-------------------------------
	; Go To Stage 4
	;-------------------------------
	jmp	stage_4

	;-------------------------------
	; Data
	;-------------------------------
.s0:	db	"3rd stage...",0x0a,0x0d,0

.s1:	db	" Font Address="
.p1:	db	"ZZZZ:"
.p2:	db	"ZZZZ",0x0a,0x0d,0

.s2:	db	" ACPI Address="
.p3:	db	"ZZZZ:"
.p4:	db	"ZZZZ",0x0a,0x0d,0

FONT:
.seg:	dw	0
.off:	dw	0

ACPI_DATA:
.addr:	dd	0
.len:	dd	0

	;-------------------------------
	; Modules
	;-------------------------------
%include "../modules/real/get_font_addr.s"
%include "../modules/real/get_mem_info.s"


;************************************************************************
; Stage 4
;************************************************************************
stage_4:
	;-------------------------------
	; Display String
	;-------------------------------
	cdecl	puts,.s0

	;-------------------------------
	; Enable A20 Gate
	;-------------------------------
	cli

	cdecl	KBC_Cmd_Write,0xad	; disable keyboard

	cdecl	KBC_Cmd_Write,0xd0	; read output port
	cdecl	KBC_Data_Read,.key

	mov	bl,[.key]		; BL = .key;
	or	bl,0x02			; BL |= 0x02; // A20Gate bit

	cdecl	KBC_Cmd_Write,0xd1	; write output port
	cdecl	KBC_Data_Write,bx

	cdecl	KBC_Cmd_Write,0xae	; enable keyboard

	sti

	;-------------------------------
	; Display String
	;-------------------------------
	cdecl	puts,.s1
	
	;-------------------------------
	; Keyboard LED Test
	;-------------------------------
	cdecl	puts,.s2

	mov	bx,0
.10L:					; do
					; {
	mov	ah,0x00			;   // wait keyboard input
	int	0x16			;   AL = BIOS(0x16, AH);
					;
	cmp	al,'1'			;   if (AL < '1')
	jb	.10E			;     break;
					;
	cmp	al,'3'			;   if (AL > '3')
	ja	.10E			;     break;
					;
	mov	cl,al			;   CL = AL;
	dec	cl			;   CL -= 1;
	and	cl,0x03			;   CL & 0x03;
	mov	ax,0x0001		;   AX = 0x0001;
	shl	ax,cl			;   AX <<= CL;
	xor	bx,ax			;   BX ^= AX;
					;
	cli				;   // prohibit interrupts
	cdecl	KBC_Cmd_Write,0xad	;   // disable keyboard

	cdecl	KBC_Data_Write,0xed	;   // LED command
	cdecl	KBC_Data_Read,.key	;

	cmp	[.key],byte 0xfa	;   if (0xfa == .key)
	jne	.11F			;   {
	cdecl	KBC_Data_Write,bx	;     // output BX
					;   }
	jmp	.11E			;   else
.11F:					;   {
	cdecl	itoa,word [.key],.e1,2,16,0b0100
	cdecl	puts,.e0
.11E:					;   }
					;
	cdecl	KBC_Cmd_Write,0xae	;   // enable keyboard
	sti				;   // permit interrupts
	jmp	.10L			; } while (1);
.10E:
	cdecl	puts,.s3

	;-------------------------------
	; Loop
	;-------------------------------
	jmp	$

	;-------------------------------
	; Data
	;-------------------------------
.s0:	db	"4th stage...",0x0a,0x0d,0
.s1:	db	" A20 Gate Enabled.",0x0a,0x0d,0
.s2:	db	" Keyboard LED Test...",0
.s3:	db	" (done)",0x0a,0x0d,0
.e0:	db	"["
.e1:	db	"ZZ]",0

.key:	dw	0

	;-------------------------------
	; Modules
	;-------------------------------
%include "../modules/real/kbc.s"

	;-------------------------------
	; Zero Padding
	;-------------------------------
	times	(BOOT_SIZE)-($-$$) db 0
