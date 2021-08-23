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
	; Display Something
	;-------------------------------
	cdecl	draw_font,63,13
	cdecl	draw_color_bar,63,4

	;-------------------------------
	; Display String
	;-------------------------------
	cdecl	draw_str,25,14,0x010F,.s0

	;-------------------------------
	; Display Time
	;-------------------------------
.10L:					; do
					; {
	cdecl	rtc_get_time,RTC_TIME	;   EAX = rtc_get_time(RTC_TIME);
	cdecl	draw_time,72,0,0x0700,dword [RTC_TIME]
	jmp	.10L			; } while (1);

	;-------------------------------
	; Loop
	;-------------------------------
	jmp	$

	;-------------------------------
	; Data
	;-------------------------------
.s0:	db	" Hello, kernel!",0

	align	4, db 0
FONT_ADDR:
	dd	0
RTC_TIME:
	dd	0

	;-------------------------------
	; Modules
	;-------------------------------
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"
%include "../modules/protect/draw_font.s"
%include "../modules/protect/draw_str.s"
%include "../modules/protect/draw_color_bar.s"
%include "../modules/protect/draw_pixel.s"
%include "../modules/protect/draw_line.s"
%include "../modules/protect/draw_rect.s"
%include "../modules/protect/itoa.s"
%include "../modules/protect/rtc.s"
%include "../modules/protect/draw_time.s"

	;-------------------------------
	; Padding
	;-------------------------------
	times	KERNEL_SIZE-($-$$) db 0x00
