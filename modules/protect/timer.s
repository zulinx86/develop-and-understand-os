; void int_en_timer0(void);
;
; Arguments
; - none
;
; Return value
; - none
int_en_timer0:
	; save registers
	push	eax

	; 8254 Timer
	; 0x2e9c (11932) = 10 [ms]
	outp	0x43,0b_00_11_010_0
	outp	0x40,0x9c
	outp	0x40,0x2e

	; restore registers
	pop	eax

	ret
