; void vga_set_read_plane(plane);
;
; Arguments
; - plane	: plane to read (0 => I, 1 => R, 2 => G, 3 => B)
;
; Return value
; - none
vga_set_read_plane:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | plane
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	edx

	; main part
	mov	ah,[ebp+8]
	and	ah,0x03
	mov	al,0x04
	mov	dx,0x03ce
	out	dx,ax

	; restore registers
	pop	edx
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

; void vga_set_write_plane(plane);
;
; Arguments
; - plane	: plane to write (0bIRGB)
;
; Return value
; - none
vga_set_write_plane:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | plane
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	edx

	; main part
	mov	ah,[ebp+8]
	and	ah,0x0f
	mov	al,0x02
	mov	dx,0x03c4
	out	dx,ax

	; restore registers
	pop	edx
	pop	eax

	; delete stack
	mov	esp,ebp
	pop	ebp

	ret

; void vram_font_copy(font, vram, plane, color);
;
; Arguments
; - font	: address to font
; - vram	: address to vram
; - plane	: plane
; - color	: color
;
; Return value
; - none
vram_font_copy:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | font
	; EBP+12 | vram
	; EBP+16 | plane
	; EBP+20 | color
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	; main part
	mov	esi,[ebp+8]		; ESI = font;
	mov	edi,[ebp+12]		; EDI = vram;
	movzx	eax,byte [ebp+16]	; EAX = plane;
	movzx	ebx,word [ebp+20]	; EBX = color;

	test	bh,al			; ZF = BH & AL; // background
	setz	dh			; DH = ZF ? 0x01 : 0x00;
	dec	dh			; DH--; // 0x00 or 0xff

	test	bl,al			; ZF = BL & AL; // foreground
	setz	dl			; DL = ZF ? 0x01 : 0x00;
	dec	dl			; DL--; // 0x00 or 0xff

	cld				; // forward direction
	mov	ecx,16			; ECX = 16;
.10L:					; do
					; {
	lodsb				;   AL = *ESI++;
	mov	ah,al			;   AH ~= AL;
	not	ah			;
					;
	and	al,dl			;   AL = AL & DL; // foreground

	test	ebx,0x0010		;   if (EBX & 0x0010) // transparent
	jz	.11F			;   {
	and	ah,[edi]		;     AH = AH & [EDI];
	jmp	.11E			;   }
.11F:					;   else
					;   {
	and	ah,dh			;     AH = AH & DH;
.11E:					;   }

	or	al,ah			;   AL = AH | AL; // merge fore and back
	mov	[edi],al		;   [EDI] = AL;

	add	edi,80			;   EDI += 80;
	loop	.10L			; } while (--ECX);
.10E:

	; restore registers
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; delete stack
	mov	esp,ebp
	pop	ebp

	ret

; void vram_bit_copy(bit, vram, flag);
;
; Arguments
; - bit		: bit pattern for output
; - vram	: address to vram
; - flag	: plane (0bIRGB)
; - color	: color
;
; Return value
; - none
vram_bit_copy:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | bit
	; EBP+12 | vram
	; EBP+16 | flag
	; EBP+20 | color
	push	ebp
	mov	ebp,esp

	; save registers
	push	eax
	push	ebx
	push	edi

	; main part
	mov	edi,[ebp+12]		; EDI = vram;
	movzx	eax,byte [ebp+16]	; EAX = flag;
	movzx	ebx,word [ebp+20]	; EBX = color;

	test	bl,al			; ZF = (BL & AL);
	setz	bl			; BL = ZF ? 0x01 : 0x00;
	dec	bl			; BL--; // 0x00 or 0xFF

	mov	al,[ebp+8]		; AL = bit
	mov	ah,al
	not	ah			; AH = ~AL;

	and	ah,[edi]		; AH &= *EDI;
	and	al,bl			; AL &= BL;
	or	al,ah			; AL |= AH;

	mov	[edi],al

	; restore registers
	pop	edi
	pop	ebx
	pop	eax

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret
