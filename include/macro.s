;************************************************************************
; Macros
;************************************************************************

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


; Set Descriptor
; Usage:
; 	set_desc	descriptor,base
%macro	set_desc 2-*
	push	eax
	push	edi

	mov	edi,%1
	mov	eax,%2

	%if 3 == %0
		mov	[edi+0],%3
	%endif

	mov	[edi+2],ax
	shr	eax,16
	mov	[edi+4],al
	mov	[edi+7],ah

	pop	edi
	pop	eax
%endmacro


;************************************************************************
; Structs
;************************************************************************

; Drive Parameter
struc drive
	.no	resw	1		; drive number
	.cyln	resw	1		; cylinder
	.head	resw	1		; head
	.sect	resw	1		; sector
endstruc


; Ring Buffer
%define	RING_ITEM_SIZE	(1 << 4)
%define RING_INDEX_MASK	(RING_ITEM_SIZE - 1)

struc ring_buff
	.rp	resd	1		; read pointer
	.wp	resd	1		; write pointer
	.item	resb	RING_ITEM_SIZE	; buffer
endstruc

