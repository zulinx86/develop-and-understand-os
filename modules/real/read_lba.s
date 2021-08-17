; WORD read_lba(drive, lba, sect, dst);
;
; Arguments
; - drive	: address to struc drive
; - lba		: LBA
; - sect	: number of sectors to read
; - dst		: destination address
;
; Return value
; - number of sectors which has been read
read_lba:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; ------|------
	; BP+ 4 | drive
	; BP+ 6 | lba
	; BP+ 8 | sect
	; BP+10 | dst
	push	bp
	mov	bp,sp

	; save registers
	push	si

	; main part
	mov	si,[bp+4]

	mov	ax,[bp+6]
	cdecl	lba_chs,si,.chs,ax

	mov	al,[si+drive.no]
	mov	[.chs+drive.no],al

	cdecl	read_chs,.chs,word [bp+8],word [bp+10]

	; restore registers
	pop	si

	; delete stack
	mov	sp,bp
	pop	bp

	ret

	align	2
.chs:	times	drive_size db 0
