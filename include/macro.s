; Function Call
; Usage:
;	cdecl	func [,param1[,param2[,...]]]
%macro	cdecl 1-*.nolist
	%rep %0 - 1
		push	%{-1:-1}
		%rotate -1
	%endrep

	%rotate -1
	call	%1

	%if 1 < %0
		add	sp,(__BITS__ >> 3) * (%0 - 1)
	%endif
%endmacro


; Drive Parameter
struc drive
	.no	resw	1	; drive number
	.cyln	resw	1	; cylinder
	.head	resw	1	; head
	.sect	resw	1	; sector
endstruc

; Set Interruption Vector
; Usage:
;	set_vect	number,handler
%macro	set_vect 1-*.nolist
	push	eax
	push	edi

	mov	edi,VECT_BASE+(%1*8)
	mov	eax,%2

	mov	[edi+0],ax
	shr	eax,16
	mov	[edi+6],ax

	pop	edi
	pop	eax
%endmacro

; Output Port
; Usage:
;	outp	number,value
%macro	outp 2
	mov	al,%2
	out	%1,al
%endmacro
