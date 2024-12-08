	.text
	.file	"task1.c"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$48, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	movl	$0, -24(%rbp)
	movb	$0, -19(%rbp)
	movl	$0, -28(%rbp)
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	xorl	%edi, %edi
	leaq	-19(%rbp), %rsi
	movl	$1, %edx
	callq	read@PLT
	movq	%rax, %rcx
	xorl	%eax, %eax
                                        # kill: def $al killed $al killed $eax
	cmpq	$0, %rcx
	movb	%al, -33(%rbp)                  # 1-byte Spill
	jle	.LBB0_3
# %bb.2:                                #   in Loop: Header=BB0_1 Depth=1
	movsbl	-19(%rbp), %eax
	cmpl	$10, %eax
	setne	%al
	movb	%al, -33(%rbp)                  # 1-byte Spill
.LBB0_3:                                #   in Loop: Header=BB0_1 Depth=1
	movb	-33(%rbp), %al                  # 1-byte Reload
	testb	$1, %al
	jne	.LBB0_4
	jmp	.LBB0_5
.LBB0_4:                                #   in Loop: Header=BB0_1 Depth=1
	movsbl	-19(%rbp), %eax
	subl	$48, %eax
	addl	-28(%rbp), %eax
	movl	%eax, -28(%rbp)
	jmp	.LBB0_1
.LBB0_5:
	movl	$9, -32(%rbp)
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movl	-28(%rbp), %eax
	movl	$10, %ecx
	cltd
	idivl	%ecx
	addl	$48, %edx
	movb	%dl, %cl
	movl	-32(%rbp), %eax
	movl	%eax, %edx
	addl	$-1, %edx
	movl	%edx, -32(%rbp)
	cltq
	movb	%cl, -18(%rbp,%rax)
	movl	-28(%rbp), %eax
	movl	$10, %ecx
	cltd
	idivl	%ecx
	movl	%eax, -28(%rbp)
# %bb.7:                                #   in Loop: Header=BB0_6 Depth=1
	cmpl	$0, -28(%rbp)
	jg	.LBB0_6
# %bb.8:
	movslq	-32(%rbp), %rax
	movl	%eax, %ecx
	leaq	-18(%rbp), %rdx
	leaq	1(%rax,%rdx), %rsi
	movl	$9, %eax
	subl	%ecx, %eax
	movslq	%eax, %rdx
	movl	$1, %edi
	movl	%edi, -40(%rbp)                 # 4-byte Spill
	callq	write@PLT
	movl	-40(%rbp), %edi                 # 4-byte Reload
	leaq	.L.str(%rip), %rsi
	movl	$1, %edx
	callq	write@PLT
	movq	%fs:40, %rax
	movq	-8(%rbp), %rcx
	cmpq	%rcx, %rax
	jne	.LBB0_10
# %bb.9:
	xorl	%eax, %eax
	addq	$48, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB0_10:
	.cfi_def_cfa %rbp, 16
	callq	__stack_chk_fail@PLT
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"\n"
	.size	.L.str, 2

	.ident	"clang version 18.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym read
	.addrsig_sym write
	.addrsig_sym __stack_chk_fail
