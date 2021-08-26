;************************************************************************
; Interrupt
;************************************************************************
;
; IDT Entry
; - Offset : 32 bit (0xOOOOoooo)
;   - Upper Offset (UO) : 16 bit (0xOOOO)
;   - Lower Offset (LO) : 16 bit (0xoooo)
; - Selector (S) : 16 bit (0xSSSS)
; - Flags (F) : 8 bit (0bPDDSTTTT)
;   - P : Present
;   - D : DPL
;   - S : Storage Segment (0 for interrupt and trap gates)
;   - T : Type
;     - 0b0101 (0x5) : 32 bit task gate
;     - 0b0110 (0x6) : 16 bit interrupt gate
;     - 0b0111 (0x7) : 16 bit trap gate
;     - 0b1110 (0xe) : 32 bit interrupt gate
;     - 0b1111 (0xf) : 32 bit trap gate
;
;  6                4        4        3               1
;  3                8        0        2               6                0
; +------------------+--------+--------+---------------+----------------+
; |        UO        |    F   |00000000|       S       |       LO       |
; +------------------+--------+--------+---------------+----------------+
;
	align	4
IDTR:	dw	8*256-1
	dd	VECT_BASE

; void init_int(void);
;
; Arguments
; - none
;
; Return value
; - none
init_int:
	; save registers
	push	eax
	push	ebx
	push	ecx
	push	edi

	; main part
	lea	eax,[int_default]	; EAX = offset to int_default;
	mov	ebx,0x0008_8e00		; EBX = segment selector & flag;
	xchg	ax,bx

	mov	ecx,256
	mov	edi,VECT_BASE

.10L:					; do {
	mov	[edi+0],ebx		;   [EDI+0] = EBX;
	mov	[edi+4],eax		;   [EDI+4] = EAX;
	add	edi,8			;   EDI += 8;
	loop	.10L			; } while (--ECX);

	lidt	[IDTR]

	pop	edi
	pop	ecx
	pop	ebx
	pop	eax

	ret

; int_default : default interruption
int_default:
	pushf
	push	cs
	push	int_stop

	mov	eax,.s0
	iret

.s0	db	" <    STOP    > ",0

; int_zero_div : interruption for zero division
int_zero_div:
	pushf
	push	cs
	push	int_stop

	mov	eax,.s0
	iret

.s0:	db	" <  ZERO DIV  > ",0

; int_stop : interruption for stop
;   display stack and loop infinitely
int_stop:
	cdecl	draw_str,25,15,0x060f,eax

	mov	eax,[esp+0]
	cdecl	itoa,eax,.p1,8,16,0b0100

	mov	eax,[esp+4]
	cdecl	itoa,eax,.p2,8,16,0b0100

	mov	eax,[esp+8]
	cdecl	itoa,eax,.p3,8,16,0b0100

	mov	eax,[esp+12]
	cdecl	itoa,eax,.p4,8,16,0b0100

	cdecl	draw_str,25,16,0x0f04,.s1
	cdecl	draw_str,25,17,0x0f04,.s2
	cdecl	draw_str,25,18,0x0f04,.s3
	cdecl	draw_str,25,19,0x0f04,.s4

	jmp	$

.s1:	db	"ESP+ 0:"
.p1:	db	"________ ",0
.s2:	db	"   + 4:"
.p2:	db	"________ ",0
.s3:	db	"   + 8:"
.p3:	db	"________ ",0
.s4:	db	"   +12:"
.p4:	db	"________ ",0
