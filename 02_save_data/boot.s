		BOOT_LOAD	equ		0x7c00

		ORG		BOOT_LOAD

entry:
		;-------------------------------
		; BPB (BIOS Parameter Block)
		;-------------------------------
		jmp		ipl
		times	90-($-$$) db 0x90

		;-------------------------------
		; IPL (Initial Program Loader)
		;-------------------------------
ipl:
		cli


		mov		ax,0x0000
		mov		ds,ax
		mov		es,ax
		mov		ss,ax
		mov		sp,BOOT_LOAD

		sti

		; dl register is set to the boot device number by BIOS
		mov		[BOOT.DRIVE],dl

		jmp		$

ALIGN 2, db 0
BOOT:
.DRIVE:	dw	0

		;-------------------------------
		; Boot Flag
		;-------------------------------
		times	510-($-$$) db 0x00
		db		0x55,0xaa
