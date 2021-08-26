; void init_pic(void);
;
; Arguments
; - none
;
; Return value
; - none
init_pic:
	; save registers
	push	eax

	; primary PIC
	outp	0x20,0x11		; PRIMARY.ICW1 = 0x11;
	outp	0x21,0x20		; PRIMARY.ICW2 = 0x20;
	outp	0x21,0x04		; PRIMARY.ICW3 = 0x04;
	outp	0x21,0x01		; PRIMARY.ICW4 = 0x01;
	outp	0x21,0xff		; primary interrupt mask

	; secondary PIC
	outp	0xa0,0x11		; SECONDARY.ICW1 = 0x11;
	outp	0xa1,0x28		; SUBONDARY.ICW2 = 0x28;
	outp	0xa1,0x02		; SUBONDARY.ICW3 = 0x02;
	outp	0xa1,0x01		; SUBONDARY.ICW4 = 0x01;
	outp	0xa1,0xff		; secondary interrupt mask

	; restore registers
	pop	eax

	ret
