;************************************************************************
; Memory Layout
;************************************************************************
	;---------------------------------------
	;             |            | 
	;             |____________| 
	; 0x0000_7a00 |      (512) | Stack in Real Mode
	;             |____________| 
	; 0x0000_7c00 |       (8K) | Boot
	;             =            = 
	;             |____________| 
	; 0x0000_9c00 |       (8K) | Kernel（Temporal）
	;             =            = 
	;             |____________| 
	; 0x0000_BC00 |////////////| 
	;             =            = 
	;             |____________| 
	; 0x0010_0000 |       (2K) | IDT
	;             |____________| 
	; 0x0010_0800 |       (2K) | Kernel Stack
	;             |____________| 
	; 0x0010_1000 |       (8K) | Kernel Program
	;             |            | 
	;             =            = 
	;             |____________| 
	; 0x0010_3000 |       (8K) | Task Stacks
	;             |            | （1K for Each Task）
	;             =            = 
	;             |____________| 

	SECT_SIZE		equ	(512)

	BOOT_LOAD		equ	0x7c00
	BOOT_SIZE		equ	(1024 * 8)
	BOOT_END		equ	(BOOT_LOAD + BOOT_SIZE)
	BOOT_SECT		equ	(BOOT_SIZE / SECT_SIZE)

	KERNEL_LOAD		equ	0x0010_1000
	KERNEL_SIZE		equ	(1024 * 8)
	KERNEL_SECT		equ	(KERNEL_SIZE / SECT_SIZE)

	E820_RECORD_SIZE	equ	20

	VECT_BASE		equ	0x0010_0000

	STACK_BASE		equ	0x0010_3000
	STACK_SIZE		equ	1024

	SP_TASK_0		equ	STACK_BASE + (STACK_SIZE * 1)
	SP_TASK_1		equ	STACK_BASE + (STACK_SIZE * 2)

