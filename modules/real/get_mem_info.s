; void get_mem_info(void);
;
; Arguments
; - none
;
; Return value
; - none
get_mem_info:
	; save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	di
	push	bp

	; main part
	cdecl	puts,.s0		; puts(.s0); // show header
					;
	mov	bp,0			; lines = 0;
	mov	ebx,0			; index = 0;
.10L:					; do
					; {
	mov	eax,0x0000E820		;   EAX = 0xE820;
	mov	ecx,E820_RECORD_SIZE	;   ECX = E820_RECORD_SIZE; // 20
	mov	edx,0x534d4150		;   EDX = "SMAP";
	mov	di,.b0			;   DI = .b0; // destination address
	int	0x15			;   BIOS(0x15,AX);

	cmp	eax,0x534d4150		;   if (EAX != "SMAP")
	je	.12E			;   {
	jmp	.10E			;     break;
.12E:					;   }
					;
	jnc	.14E			;   if (CF) // 0 => success, 1 => fail
					;   {
	jmp	.10E			;     break;
.14E:					;   }
					;
	cdecl	put_mem_info,di		;   put_mem_info(di);
	mov	eax,[di+16]		;   EAX = type;
	cmp	eax,3			;   if (EAX == 3) // ACPI data
	jne	.15E			;   {
	mov	eax,[di+0]		;     EAX = base;
	mov	[ACPI_DATA.addr],eax	;     ACPI_DATA.addr = EAX;
	mov	eax,[di+8]              ;     EAX = len;
	mov	[ACPI_DATA.len],eax	;     APCI_DATA.len = EAX;
.15E:					;   }
					;
	cmp	ebx,0			;   if (EBX != 0)
	jz	.16E			;   {
	inc	bp			;     lines++;
	and	bp,0x07			;     lines &= 0x07;
	jnz	.16E			;     if (lines == 0)
					;     {
	cdecl	puts,.s2		;       puts(.s2);
	mov	ah,0x10			;       AH = 0x10;
	int	0x16			;       AL = BIOS(0x16,AH); // wait key
	cdecl	puts,.s3		;       puts(.s3);
					;     }
.16E:					;   }
	cmp	ebx,0			; }
	jne	.10L			; while (EBX != 0);
.10E:					;
	cdecl	puts,.s1		; puts(.s1); // show footer

	; restore registers
	pop	bp
	pop	di
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	ret

.s0:	db " E820 Memory Map:", 0x0A, 0x0D
	db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	db " <more...>", 0
.s3:	db 0x0D, "          ", 0x0D, 0

	align	4, db 0
.b0:	times	E820_RECORD_SIZE db 0


; void put_mem_info(addr);
;
; Arguments
; - addr	: address of memory info
;
; Return value
; - none
put_mem_info:
	; stack frame
	; BP+ 0 | original BP
	; BP+ 2 | return address (IP)
	; BP+ 4 | addr
	push	bp
	mov	bp,sp

	; save registers
	push	bx
	push	si

	; main part
	mov	si,[bp+4]		; SI = addr;

	; Base (64 bit)
	cdecl	itoa,word [si+6],.p2+0,4,16,0b0100
	cdecl	itoa,word [si+4],.p2+4,4,16,0b0100
	cdecl	itoa,word [si+2],.p3+0,4,16,0b0100
	cdecl	itoa,word [si+0],.p3+4,4,16,0b0100

	; Length (64 bit)
	cdecl	itoa,word [si+14],.p4+0,4,16,0b0100
	cdecl	itoa,word [si+12],.p4+4,4,16,0b0100
	cdecl	itoa,word [si+10],.p5+0,4,16,0b0100
	cdecl	itoa,word [si+ 8],.p5+4,4,16,0b0100

	; Type (32 bit)
	cdecl	itoa,word [si+18],.p6+0,4,16,0b0100
	cdecl	itoa,word [si+16],.p6+4,4,16,0b0100

	cdecl	puts,.s1

	mov	bx,[si+16]
	and	bx,0x07
	shl	bx,1
	add	bx,.t0			; BX = .t0 + (type & 0x07) << 1;
	cdecl	puts,word [bx]

	; restore registers
	pop	si
	pop	bx

	; delete stack
	mov	sp,bp
	pop	bp

	ret

.s1:	db	" "
.p2:	db	"ZZZZZZZZ_"
.p3:	db	"ZZZZZZZZ "
.p4:	db	"ZZZZZZZZ_"
.p5:	db	"ZZZZZZZZ "
.p6:	db	"ZZZZZZZZ",0

.s4:	db	" (unknown)",0x0a,0x0d,0
.s5:	db	" (available)",0x0a,0x0d,0
.s6:	db	" (reserved)",0x0a,0x0d,0
.s7:	db	" (ACPI data)",0x0a,0x0d,0
.s8:	db	" (ACPI NVS)",0x0a,0x0d,0
.s9:	db	" (bad memory)",0x0a,0x0d,0

.t0:	dw	.s4,.s5,.s6,.s7,.s8,.s9,.s4,.s4
