; WORD KBC_Data_Write(data);
;
; Arguments
; - data	: data to write
;
; Return value
; - 0		: fail
; - non 0	: success
KBC_Data_Write:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | data
	push	bp
	mov	bp,sp

	; save registers
	push	cx

	; main part
	mov	cx,0
.10L:				; do
				; {
	in	al,0x64		;   AL = in(0x64);
	test	al,0x02		;   ZF = AL & 0x02;
	loopnz	.10L		; } while (--CX != 0 && ZF != 0);

	cmp	cx,0		; if (CX)
	jz	.20E		; {
	mov	al,[bp+4]	;   AL = data;
	out	0x60,al		;   out(0x60, AL);
.20E:				; }
	mov	ax,cx

	; restore registers
	pop	cx

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret


; WORD KBC_Data_Read(data);
;
; Arguments
; - data	: address to store data
;
; Return value
; - 0		: fail
; - non 0	: success
KBC_Data_Read:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | data
	push	bp
	mov	bp,sp

	; save registers
	push	cx
	push	di

	; main part
	mov	cx,0
.10L:				; do
				; {
	in	al,0x64		;   AL = in(0x64);
	test	al,0x01		;   ZF = AL & 0x01;
	loopz	.10L		; } while (--CX != 0 && ZF == 0);

	cmp	cx,0		; if (CX)
	jz	.20E		; {
	mov	ah,0x00		;   AH = 0x00;
	in	al,0x60		;   AL = in(0x60);
	mov	di,[bp+4]	;   DI = data;
	mov	[di+0],ax	;   *DI = AX;
.20E:				; }
	mov	ax,cx

	; restore registers
	pop	di
	pop	cx

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret

; WORD KBC_Cmd_Write(cmd);
;
; Arguments
; - cmd		: command
;
; Return value
; - 0		: fail
; - non 0	: success
KBC_Cmd_Write:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | cmd
	push	bp
	mov	bp,sp

	; save registers
	push	cx

	; main part
	mov	cx,0
.10L:				; do
				; {
	in	al,0x64		;   AL = in(0x64);
	test	al,0x02		;   ZF = AL & 0x02;
	loopnz	.10L		; } while (--CX != 0 && ZF != 0);

	cmp	cx,0		; if (CX != 0)
	jz	.20E		; {
	mov	al,[bp+4]	;   AL = cmd;
	out	0x64,al		;   out(0x64, AL);
.20E:				; }

	mov	ax,cx

	; restore registers
	pop	cx

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret

