; TSS
TSS_0:
.link:		dd	0
.esp0:		dd	SP_TASK_0 - 512
.ss0:		dd	DS_KERNEL
.esp1:		dd	0
.ss1:		dd	0
.esp2:		dd	0
.ss2:		dd	0
.cr3:		dd	0
.eip:		dd	0
.eflags:	dd	0
.eax:		dd	0
.ecx:		dd	0
.edx:		dd	0
.ebx:		dd	0
.esp:		dd	0
.ebp:		dd	0
.esi:		dd	0
.edi:		dd	0
.es:		dd	0
.cs:		dd	0
.ss:		dd	0
.ds:		dd	0
.fs:		dd	0
.gs:		dd	0
.ldt:		dd	0
.io:		dd	0

TSS_1:
.link:		dd	0
.esp0:		dd	SP_TASK_1 - 512
.ss0:		dd	DS_KERNEL
.esp1:		dd	0
.ss1:		dd	0
.esp2:		dd	0
.ss2:		dd	0
.cr3:		dd	0
.eip:		dd	task_1
.eflags:	dd	0x0202
.eax:		dd	0
.ecx:		dd	0
.edx:		dd	0
.ebx:		dd	0
.esp:		dd	SP_TASK_1
.ebp:		dd	0
.esi:		dd	0
.edi:		dd	0
.es:		dd	DS_TASK_1
.cs:		dd	CS_TASK_1
.ss:		dd	DS_TASK_1
.ds:		dd	DS_TASK_1
.fs:		dd	DS_TASK_1
.gs:		dd	DS_TASK_1
.ldt:		dd	SS_LDT
.io:		dd	0


; Global Descriptor Table
GDT:		dq	0x00_0_0_00_000000_0000
.cs_kernel:	dq	0x00_c_f_9a_000000_ffff
.ds_kernel:	dq	0x00_c_f_92_000000_ffff
.ldt:		dq	0x00_0_0_82_000000_0000
.tss_0:		dq	0x00_0_0_89_000000_0067
.tss_1:		dq	0x00_0_0_89_000000_0067
.end:

CS_KERNEL	equ	.cs_kernel - GDT
DS_KERNEL	equ	.ds_kernel - GDT
SS_LDT		equ	.ldt - GDT
SS_TASK_0	equ	.tss_0 - GDT
SS_TASK_1	equ	.tss_1 - GDT

GDTR:		dw	GDT.end - GDT - 1
		dd	GDT


; Local Descriptor Table
LDT:		dq	0x00_0_0_00_000000_0000
.cs_task_0:	dq	0x00_c_f_9a_000000_ffff
.ds_task_0:	dq	0x00_c_f_92_000000_ffff
.cs_task_1:	dq	0x00_c_f_9a_000000_ffff
.ds_task_1:	dq	0x00_c_f_92_000000_ffff
.end:

CS_TASK_0	equ	(.cs_task_0 - LDT) | 4
DS_TASK_0	equ	(.ds_task_0 - LDT) | 4
CS_TASK_1	equ	(.cs_task_0 - LDT) | 4
DS_TASK_1	equ	(.ds_task_0 - LDT) | 4

LDT_LIMIT	equ	.end - LDT - 1
