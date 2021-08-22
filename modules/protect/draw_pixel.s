; void draw_pixel(x, y, color);
;
; Arguments
; - x		: x
; - y		: y
; - color	: color
;
; Return value
; - none
draw_pixel:
	; stack frame
	; EBP+ 0 | original EBP
	; EBP+ 4 | return address (EIP)
	; -------|-------
	; EBP+ 8 | x
	; EBP+12 | y
	; EBP+16 | color
	push	ebp
	mov	ebp,esp

	; save registers
	push	ebx
	push	ecx
	push	edi

	; main part
	mov	edi,[ebp+12]		; EDI = y * 80;
	shl	edi,4
	lea	edi,[edi*4+edi+0x000a_0000]

	mov	ebx,[ebp+8]
	shr	ebx,3
	add	edi,ebx			; EDI += x / 8;

	mov	ecx,[ebp+8]
	and	ecx,0x07
	mov	ebx,0x80
	shr	ebx,cl			; EBX = 0x80 >> (x & 0x07);

	mov	ecx,[ebp+16]		; ECX = color;

	cdecl	vga_set_read_plane,0x03
	cdecl	vga_set_write_plane,0x08
	cdecl	vram_bit_copy,ebx,edi,0x08,ecx

	cdecl	vga_set_read_plane,0x02
	cdecl	vga_set_write_plane,0x04
	cdecl	vram_bit_copy,ebx,edi,0x04,ecx

	cdecl	vga_set_read_plane,0x01
	cdecl	vga_set_write_plane,0x02
	cdecl	vram_bit_copy,ebx,edi,0x02,ecx

	cdecl	vga_set_read_plane,0x00
	cdecl	vga_set_write_plane,0x01
	cdecl	vram_bit_copy,ebx,edi,0x01,ecx

	; restore registers
	pop	edi
	pop	ecx
	pop	ebx

	; delete stack
	mov	esp,ebp
	pop	ebp

	ret
