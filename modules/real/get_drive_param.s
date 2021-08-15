; WORD get_drive_param(drive);
;
; Arguments
; - drive	: address to struc drive
;
; Return value
; - 0		: fail
; - non 0	: success
get_drive_param:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | drive
	push	bp
	mov	bp,sp

	; save registers
	push	bx
	push	cx
	push	dx
	push	es
	push	si
	push	di

	; main part
	mov	si,[bp+4]		; SI = drive;

	mov	ax,0
	mov	es,ax			; ES = 0x0000;
	mov	di,ax			; DI = 0x0000;

	mov	ah,0x08			; function to get drive params
	mov	dl,[si+drive.no]	; DL = drive number
	int	0x13			; CF = BIOS(0x13, AH);
.10Q:	jc	.10F			; if (CF == 0)
.10T:					; {
	mov	al,cl			;
	and	ax,0x3F			;   AL = CL[5:0]; // sector
	shr	cl,6			;
	ror	cx,8			;
	inc	cx			;   CX = (CL[7:6] << 8) + CH + 1; // cylinder
	movzx	bx,dh			;
	inc	bx			;   BX = DH + 1; // head
	mov	[si+drive.cyln],cx	;   drive.cyln = CX;
	mov	[si+drive.head],bx	;   drive.head = BX;
	mov	[si+drive.sect],ax	;   drive.sect = AX;
	jmp	.10E			; }
.10F:					; else
					; {
	mov	ax,0			;   AX = 0;
.10E:					; }

	; restore registers
	pop	di
	pop	si
	pop	es
	pop	dx
	pop	cx
	pop	bx

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret
