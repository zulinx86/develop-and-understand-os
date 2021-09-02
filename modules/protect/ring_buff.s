; DWORD ring_rd(buff, data);
;
; Arguments
; - buff	: ring buffer
; - data	: address to store data
;
; Return value
; - 0		: data exists
; - non 0	: data doesn't exist
ring_rd:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | buff
	; EBP+12 | data
	push	ebp
	mov	ebp,esp

	; save registers
	push	ebx
	push	esi
	push	edi

	; get arguments
	mov	esi,[ebp+8]
	mov	edi,[ebp+12]

	; read data from ring buffer
	mov	eax,0			; EAX = 0;
	mov	ebx,[esi+ring_buff.rp]	; EBX = rp;
	cmp	ebx,[esi+ring_buff.wp]	; if (EBX != wp)
	je	.10E			; {
	mov	al,[esi+ring_buff.item + ebx]
					;   AL = buff[rp];
	mov	[edi],al		;   *EDI = AL;
	inc	ebx			;   ++EBX;
	and	ebx,RING_INDEX_MASK	;   EBX &= 0x0f;
	mov	[esi+ring_buff.rp],ebx	;   ring_buff.rp = EBX;
					;
	mov	eax,1			;   EAX = 1; // return value
.10E:					; }

	; restore registers
	pop	edi
	pop	esi
	pop	ebx

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

; DWORD ring_wr(buff, data);
;
; Arguments
; - buff	: ring buffer
; - data	: data to write
;
; Return value
; - 0		: success
; - non 0	: fail
ring_wr:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | buff
	; EBP+12 | data
	push	ebp
	mov	ebp,esp

	; save registers
	push	ebx
	push	ecx
	push	esi

	; get arguments
	mov	esi,[ebp+8]		; ESI = buff;

	; write data to ring buffer
	mov	eax,0			; EAX = 0;
	mov	ebx,[esi+ring_buff.wp]	; EBX = wp;

	mov	ecx,ebx;		; ECX = EBX;
	inc	ecx			; ++ECX;
	and	ecx,RING_INDEX_MASK	; ECX &= 0x0f;
	cmp	ecx,[esi+ring_buff.rp]	; if (ECX != rp)
	je	.10E			; {
	mov	al,[ebp+12]		;   AL = data;
	mov	[esi+ring_buff.item+ebx],al
					;   buff[wp] = AL;
	mov	[esi+ring_buff.wp],ecx	;   wp = ECX;

	mov	eax,0			;   EAX = 0; // return value
.10E:					; }

	; restore registers
	pop	esi
	pop	ecx
	pop	ebx

	; delete stack
	mov	esp,ebp
	pop	ebp

	ret


; void draw_key(col, row, buff);
;
; Arguments
; - col		: column
; - row		: row
; - buff	: address to ring buffer
;
; Return value
; - none
draw_key:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | col
	; EBP+12 | row
	; EBP+16 | buff
	push	ebp
	mov	ebp,esp

	; save registers
	pusha

	; get arguments
	mov	edx,[ebp+8]		; EDX = col;
	mov	edi,[ebp+12]		; EDI = row;
	mov	esi,[ebp+16]		; ESI = buff;

	; read data from ring buffer
	mov	ebx,[esi+ring_buff.wp]	; EBX = wp;
	lea	esi,[esi+ring_buff.item]; ESI = &buff[0];
	mov	ecx,RING_ITEM_SIZE	; ECX = RING_ITEM_SIZE;

	; display
.10L:					; do
					; {
	dec	ebx			;   --EBX;
	and	ebx,RING_INDEX_MASK	;   EBX &= RING_INDEX_MASK;
	mov	al,[esi+ebx]		;   EAX = buff[EBX];

	cdecl	itoa,eax,.tmp,2,16,0b0100
	cdecl	draw_str,edx,edi,0x02,.tmp

	add	edx,3			;   EDX += 3;
	
	loop	.10L			; 
.10E:					; } while (--ECX);

	; restore registers
	popa

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

.tmp:	db	"-- ",0
