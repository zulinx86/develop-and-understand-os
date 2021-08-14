; void reboot(void);
;
; Arguments
; - none
;
; Return value
; - none
reboot:
	; display message
	cdecl	puts,.s0

	; wait for a key input
.10L:				; do
				; {
	mov	ah,0x10		;   AH = 0x10;
	int	0x16		;   AL = BIOS(0x16, AH);
				;
	cmp	al,' '		;   ZF = (AL == ' ');
	jne	.10L		; } while (!ZF);

	; display new lines
	cdecl	puts,.s1

	; reboot
	int	0x19		; BIOS(0x19);

	; string data
.s0	db	0x0a,0x0d,"Push SPACE key to reboot...",0
.s1	db	0x0a,0x0d,0x0a,0x0d,0
