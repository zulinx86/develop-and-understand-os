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
	; Set Up GDT
	;-------------------------------
	set_desc	GDT.tss_0,TSS_0
	set_desc	GDT.tss_1,TSS_1
	set_desc	GDT.ldt,LDT,word LDT_LIMIT
	lgdt	[GDTR]

	;-------------------------------
	; Jump To Task 0
	;-------------------------------
	mov	esp,SP_TASK_0
	mov	ax,SS_TASK_0
	ltr	ax

	;-------------------------------
	; Initialize Interruption
	;-------------------------------
	cdecl	init_int
	cdecl	init_pic

	set_vect	0x00,int_zero_div
	set_vect	0x20,int_timer
	set_vect	0x21,int_keyboard
	set_vect	0x28,int_rtc

	cdecl	rtc_int_en,0x10
	cdecl	int_en_timer0

	outp	0x21,0b1111_1000	; enable secondary PIC / KBC / timer
	outp	0xa1,0b1111_1110	; enable RTC

	sti

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
	; Loop
	;-------------------------------
	call	SS_TASK_1:0

.10L:					; do
					; {
	;-------------------------------
	; Display Time
	;-------------------------------
	mov	eax,[RTC_TIME]
	cdecl	draw_time,72,0,0x0700,eax

	;-------------------------------
	; Display Rotation Bar
	;-------------------------------
	cdecl	draw_rotation_bar

	;-------------------------------
	; Get Key Code
	;-------------------------------
	cdecl	ring_rd,_KEY_BUFF,.int_key
	;cmp	eax,0
	;je	.10E

	;-------------------------------
	; Display Key Code
	;-------------------------------
	cdecl	draw_key,2,29,_KEY_BUFF
.10E:
	jmp	.10L			; } while (1);

	;-------------------------------
	; Data
	;-------------------------------
.s0:	db	" Hello, kernel! ",0

	align	4, db 0
.int_key:
	dd	0

	align	4, db 0
FONT_ADDR:
	dd	0
RTC_TIME:
	dd	0

	;-------------------------------
	; Modules
	;-------------------------------
%include "descriptor.s"
%include "tasks/task_1.s"

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
%include "../modules/protect/interrupt.s"
%include "../modules/protect/pic.s"
%include "../modules/protect/int_rtc.s"
%include "../modules/protect/int_keyboard.s"
%include "../modules/protect/ring_buff.s"
%include "../modules/protect/timer.s"
%include "../modules/protect/draw_rotation_bar.s"
%include "modules/int_timer.s"

	;-------------------------------
	; Padding
	;-------------------------------
	times	KERNEL_SIZE-($-$$) db 0x00
