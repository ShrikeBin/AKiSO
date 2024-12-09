	.file	"task1.c"
	.text
	.section	.rodata
.LC0:
	.string	"\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movb	$0, -29(%rbp)
	movl	$0, -28(%rbp)
	jmp	.L2
.L4:
	movzbl	-29(%rbp), %eax
	movsbl	%al, %eax
	subl	$48, %eax
	addl	%eax, -28(%rbp)
.L2:
	leaq	-29(%rbp), %rax
	movl	$1, %edx
	movq	%rax, %rsi
	movl	$0, %edi
	call	read@PLT
	testq	%rax, %rax
	jle	.L3
	movzbl	-29(%rbp), %eax
	cmpb	$10, %al
	jne	.L4
.L3:
	movl	$9, -24(%rbp)
.L5:
	movl	-28(%rbp), %edx
	movslq	%edx, %rax
	imulq	$1717986919, %rax, %rax
	shrq	$32, %rax
	movl	%eax, %ecx
	sarl	$2, %ecx
	movl	%edx, %eax
	sarl	$31, %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	sall	$2, %eax
	addl	%ecx, %eax
	addl	%eax, %eax
	movl	%edx, %ecx
	subl	%eax, %ecx
	movl	%ecx, %eax
	leal	48(%rax), %ecx
	movl	-24(%rbp), %eax
	leal	-1(%rax), %edx
	movl	%edx, -24(%rbp)
	movl	%ecx, %edx
	cltq
	movb	%dl, -18(%rbp,%rax)
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	imulq	$1717986919, %rdx, %rdx
	shrq	$32, %rdx
	movl	%edx, %ecx
	sarl	$2, %ecx
	cltd
	movl	%ecx, %eax
	subl	%edx, %eax
	movl	%eax, -28(%rbp)
	cmpl	$0, -28(%rbp)
	jg	.L5
	movl	$9, %eax
	subl	-24(%rbp), %eax
	cltq
	movl	-24(%rbp), %edx
	addl	$1, %edx
	leaq	-18(%rbp), %rcx
	movslq	%edx, %rdx
	addq	%rdx, %rcx
	movq	%rax, %rdx
	movq	%rcx, %rsi
	movl	$1, %edi
	call	write@PLT
	movl	$1, %edx
	leaq	.LC0(%rip), %rax
	movq	%rax, %rsi
	movl	$1, %edi
	call	write@PLT
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L7
	call	__stack_chk_fail@PLT
.L7:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 14.2.1 20240910"
	.section	.note.GNU-stack,"",@progbits
