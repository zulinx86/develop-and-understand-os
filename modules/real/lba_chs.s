; void lba_chs(drive, chs, lba);
;
; Arguments
; - drive	: address to struc drive which has drive parameters
; - chs		: address to struc drive which has converted CHS values
; - lba		: lba
;
; Return address
; - 0		: fail
; - non 0	: success
lba_chs:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; ------|------
	; BP+ 4 | drive
	; BP+ 6 | chs
	; BP+ 8 | lba
	push	bp
	mov	bp,sp

	; save registers
	push	ax
	push	bx
	push	dx
	push	si
	push	di

	; main part
	mov	si,[bp+4]		; SI = drive;
	mov	di,[bp+6]		; DI = chs;

	mov	al,[si+drive.head]	; AL = head;
	mul	byte [si+drive.sect]	; AX = haed * sect;
	mov	bx,ax			; BX = number of sectors per cylinder

	mov	dx,0			; DX = lba; // upper 2 bytes
	mov	ax,[bp+8]		; AX = lba; // lower 2 bytes
	div	bx			; DX = DX:AX % BX;
					; AX = DX:AX / BX;

	mov	[di+drive.cyln],ax	; chs.cyln = AX;

	mov	ax,dx			; AX = DX; // remaining sectors
	div	byte [si+drive.sect]	; AH = AX % sect; // sector
					; AL = AX / sect; // head
	movzx	dx,ah			; DX = sect;
	inc	dx			;
	mov	ah,0x00			; AX = head;

	mov	[di+drive.head],ax	; chs.head = AX;
	mov	[di+drive.sect],dx	; chs.sect = DX;

	; restore registers
	pop	di
	pop	si
	pop	dx
	pop	bx
	pop	ax

	; delete stack
	mov	sp,bp
	pop	bp

	ret
