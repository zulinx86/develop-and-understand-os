; void draw_char(col, row, color, ch);
;
; Arguments
; - col		: column (0 - 79)
; - row		: row (0 - 29)
; - color	: color
; - ch		; character
;
; Return value
; - none
draw_char:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | col
	; EBP+12 | row
	; EBP+16 | color
	; EBP+20 | ch
	push	ebp
	mov	ebp,esp

	; save registers
	push	ebx
	push	esi
	push	edi

	; source address
	movzx	esi,byte [ebp+20]	; ESI = ch;
	shl	esi,4			; ESI *= 16;
	add	esi,[FONT_ADDR]		; ESI += *FONT_ADDR;

	; destination address
	; 0x000a_0000 + (640 / 8 * 16) * y + x
	mov	edi,[ebp+12]		; EDI = row;
	shl	edi,8			; EDI = (EDI * 1280) + 0x000a_0000;
	lea	edi,[edi*4+edi+0x000a_0000]
	add	edi,[ebp+8]		; EDI += col;

	; display a character
	movzx	ebx,word [ebp+16]

	cdecl	vga_set_read_plane,0x03
	cdecl	vga_set_write_plane,0x08
	cdecl	vram_font_copy,esi,edi,0x08,ebx

	cdecl	vga_set_read_plane,0x02
	cdecl	vga_set_write_plane,0x04
	cdecl	vram_font_copy,esi,edi,0x04,ebx

	cdecl	vga_set_read_plane,0x01
	cdecl	vga_set_write_plane,0x02
	cdecl	vram_font_copy,esi,edi,0x02,ebx

	cdecl	vga_set_read_plane,0x00
	cdecl	vga_set_write_plane,0x01
	cdecl	vram_font_copy,esi,edi,0x01,ebx

	; restore registers
	pop	edi
	pop	esi
	pop	ebx

	; delete stack frame
	mov	esp,ebp
	pop	ebp

	ret

