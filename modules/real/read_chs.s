; WORD read_chs(drive, sect, dst);
;
; Arguments
; - drive	: address to struct drive
; - sect	: the number of sectors
; - dst		: destination address to read
;
; Return address
; - the numbers of sectors that have been read
read_chs:
	; stack frame
	; BP- 4 | sect = 0;
	; BP- 2 | retry = 3;
	; ------|------
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; ------|------
	; BP+ 4 | drive
	; BP+ 6 | sect
	; BP+ 8 | dst
	push	bp
	mov	bp,sp
	push	3
	push	0

	; save registers
	push	bx
	push	cx
	push	dx
	push	es
	push	si
	
	; main part
	mov	si,[bp+4]
	mov	ch,[si+drive.cyln+0]	; CH = drive.cyln & 0xff
	mov	cl,[si+drive.cyln+1]	; CL = drive.cyln >> 8
	shl	cl,6			; CL <<= 6;
	or	cl,[si+drive.sect]	; CL |= drive.sect

	mov	dh,[si+drive.head]	; DH = drive.head
	mov	dl,[si+drive.no]	; DL = drive.no
	mov	ax,0x0000
	mov	es,ax			; ES = 0x0000
	mov	bx,[bp+8]		; BX = dst;

.10L:					; do
					; {
	mov	ah,0x02			;   AH = 0x02; // function to read sector
	mov	al,[bp+6]		;   AL = sect;
					;
	int	0x13			;   CF = BIOS(0x13, AH);
	jnc	.11E			;   if (CF) // 1 : fail, 0 | success
					;   {
	mov	al,0			;     AL = 0;
	jmp	.10E			;     break;
.11E:					;   }
	cmp	al,0			;   if (AL != 0)
	jne	.10E			;     break;
					;
	mov	ax,0			;   ret = 0;
	dec	word [bp-2]		; } while (--retry);
	jnz	.10L			;
.10E:
	mov	ah,0

	; restore registers
	pop	si
	pop	es
	pop	dx
	pop	cx
	pop	bx

	; delete stack frame
	mov	sp,bp
	pop	bp

	ret
