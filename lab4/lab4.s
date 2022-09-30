	.arch armv8-a

/* A^2 - B^2 - (A + B) * (A - B) */

    .data
usage:
    /* .string - assembly automatically adds \0 */
	.string "Usage: %s file\n"
format:
	.string	"Incorrect format of file...\n"
size:
	.string	"Dimension of matrix must be less or equal to 20!\n"
formint:
	.string	"%d"
formdouble:
	.string "%lf"
eloutput:
    .string "%.2lf "
smile:
    .string "smile :}\n"
resmes:
    .string "Result:\n"
newline:
    .string "\n"
mode:
	.string "r" /* r - open file to read */
temp_matrix1:
    .skip   400*8
temp_matrix2:
    .skip   400*8
temp_matrix3:
    .skip   400*8
    .text
	.align	2
	.global	main
	.type	main, %function
    /* Form stack frame
     * argv - 4 registers for main (lib funcs) */
	.equ	progname, 32 /* argv */
	.equ	filename, 40
	.equ	filestruct, 48 /* ptr to struct */
	.equ	n, 56
	.equ	matrixA, 64
    .equ    matrixB, 3264
    .equ    res, 6464

main:
    mov x26, #9664
	sub	sp, sp, x26
	stp	x29, x30, [sp]
	stp	x27, x28, [sp, #16]
	mov	x29, sp /* form new stack frame */
	cmp	w0, #2
	beq	0f
	ldr	x2, [x1] /* x1 - progname */
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, usage
	bl	fprintf
9:
    /* Game over */
	mov	w0, #1
	ldp	x29, x30, [sp]
	ldp	x27, x28, [sp, #16]
	add	sp, sp, x26
	ret
0:
    /* Form parameters for fopen */
	ldr	x0, [x1]
	str	x0, [x29, progname]
	ldr	x0, [x1, #8]
	str	x0, [x29, filename]
	adr	x1, mode
	bl	fopen
	cbnz	x0, 1f /* error - fopen return NULL */
	ldr	x0, [x29, filename]
	bl	perror /* perror prints error mes */
	b	9b
1:
    /* x0 - pointer to opened file */
	str	x0, [x29, filestruct]
    /* Read n */
	adr	x1, formint
	add	x2, x29, n /* x2 - address at which read number will be saved */
	bl	fscanf
	cmp	w0, #1 /* succes - 1 integer */
	beq	2f
	ldr	x0, [x29, filestruct]
	bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, format
	bl	fprintf
	b	9b
2:
	mov	x27, #0 /* x27 - counter */
	ldr	w28, [x29, n] /* x28 - n (0 < n <= 20) */
	cmp	x28, #0
	ble	3f
	cmp	x28, #20
	bgt	3f
	mul	x28, x28, x28 /* x28 - n*n */
	b	4f
3:
    /* Error handling */
	ldr	x0, [x29, filestruct]
	bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, size
	bl	fprintf
	b	9b
4:
    /* Read matrix A */
	ldr	x0, [x29, filestruct]
    ldr x1, [x29, n]
    mov x2, matrixA
    add x2, x2, x29
    bl  read_matrix
    /* Read matrix B */
	ldr	x0, [x29, filestruct]
    ldr x1, [x29, n]
    mov x2, matrixB
    add x2, x2, x29
    bl  read_matrix
    /* Matrices are read -> close file */
	ldr	x0, [x29, filestruct]
	bl	fclose
	mov	x1, #0
5:
    adr x21, temp_matrix1
    /* A^2 */
    ldr w0, [x29, n]
    mov x1, matrixA
    add x1, x1, x29
    mov x2, matrixA
    add x2, x2, x29
    mov x3, x21 /* x21 - temp matrix */
    bl  multiply_matrices

    adr x22, temp_matrix2
    /* B^2 */
    ldr w0, [x29, n]
    mov x1, matrixB
    add x1, x1, x29
    mov x2, matrixB
    add x2, x2, x29
    mov x3, x22 /* x22 - temp matrix */
    bl  multiply_matrices

    /* A^2 - B^2 */
    ldr w0, [x29, n]
    mov x1, x21
    mov x2, x22
    mov x3, res
    add x3, x3, x29
    bl  substract_matrices
    mov x27, #0
	ldr	w28, [x29, n]
    mul x28, x28, x28
    adr x21, temp_matrix1

6:
    /* A + B */
    cmp x27, x28
    bge 7f
	lsl	x1, x27, #3 /* x2 - address for reading */
	add	x1, x1, x29
    add x2, x1, matrixA
    ldr d0, [x2]
    add x3, x1, matrixB
    ldr d1, [x3]
    fadd    d2, d1, d0
    str d2, [x21, x27, lsl #3]
    add x27, x27, #1
    b   6b
7:
    /* A - B */
    adr x22, temp_matrix2
    ldr w0, [x29, n]
    mov x1, matrixA
    add x1, x1, x29
    mov x2, matrixB
    add x2, x2, x29
    adr x3, temp_matrix2
    bl  substract_matrices

    adr x23, temp_matrix3
    ldr w0, [x29, n]
    adr x1, temp_matrix1
    adr x2, temp_matrix2
    adr x3, temp_matrix3
    bl  multiply_matrices

    ldr w0, [x29, n]
    mov x1, res
    add x1, x1, x29
    adr x2, temp_matrix3
    mov x3, x1
    bl  substract_matrices

    /* Output result */
    adr x0, resmes
    bl  printf
    ldr w0, [x29, n]
    mov x1, res
    add x1, x1, x29
    bl  print_matrix
8:
	mov	w0, #0
	ldp	x29, x30, [sp]
	ldp	x27, x28, [sp, #16]
    mov x26, #9664
	add	sp, sp, x26
	ret
	.size	main, .-main
    .global substract_matrices
    .type   substract_matrices, %function
substract_matrices:
    /* x0 - n
     * x1 - matrix1
     * x2 - matrix2
     * x3 - res */
    stp x29, x30, [sp, #-16]!
    mov x4, #0
    mul x5, x0, x0 /* x5 - n*n */
0:
    cmp x4, x5
    bge 1f
    ldr d0, [x1, x4, lsl #3]
    ldr d1, [x2, x4, lsl #3]
    fsub    d2, d0, d1
    str d2, [x3, x4, lsl #3]
    add x4, x4, #1
    b   0b
1:
    ldp x29, x30, [sp], #16
    ret
    .size   substract_matrices, .-substract_matrices
    .global multiply_matrices
    .type   multiply_matrices, %function
multiply_matrices:
    /* x0 - n
     * x1 - matrix1
     * x2 - matrix2
     * x3 - res */
    stp x29, x30, [sp, #-16]!
    mov     x15, #0
    mov     x5, #0
0:
    cmp     x5, x0
    bge     4f
    mov     x4, #0
    mul     x11, x5, x0
    add     x16, x1, x11, lsl #3
    add     x17, x3, x11, lsl #3
    add     x5, x5, #1
1:
    cmp     x4, x0
    bge     0b
    add     x7, x2, x4, lsl #3
    mov     x6, #0
    fmov    d0, x15
2:
    cmp     x6, x0
    beq     3f
    ldr     d1, [x7]
    ldr     d2, [x16, x6, lsl #3]
    fmadd   d0, d1, d2, d0
    add     x6, x6, #1
    add     x7, x7, x0, lsl #3
    b       2b
3:
    str     d0, [x17, x4, lsl #3]
    add     x4, x4, #1
    b       1b
4:
    ldp x29, x30, [sp], #16
    ret
    .size   multiply_matrices, .-multiply_matrices
    .global read_matrix
    .type   read_matrix, %function
read_matrix:
    /* x0 - filestruct
     * x1 - n
     * x2 - matrix */
    stp x29, x30, [sp, #-16]!
    mov x26, x0 /* x26 - filestruct */
    mov x25, x2 /* x25 - matrix */
    mul x28, x1, x1 /* x28 - n*n */
    mov x27, #0
    mov x2, #0
0:
    mov x0, x26
    adr	x1, formdouble
    lsl	x2, x27, #3 /* x2 - address for reading */
	add x2, x2, x25
    bl	fscanf
	cmp	w0, #1 /* Is one element read? */
	beq	1f
    mov x0, x26
    bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, format
	bl	fprintf
	b	2f
1:
	add	x27, x27, #1
	cmp	x27, x28
	bne	0b
2:
    ldp x29, x30, [sp], #16
    ret
    .size   read_matrix, .-read_matrix
    .global print_matrix
    .type   print_matrix, %function
print_matrix:
    /* x0 - n
     * x1 - matrix */
    stp x29, x30, [sp, #-16]!
    mul x28, x0, x0 /* x28 - n*n */
    mov x25, x0 /* x0 - n */
    mov x24, x1 /* x24 - matrix */
    mov x27, #0
    mov x26, #0
0:
    /* Output element */
    cmp x27, x28
    bge 2f
	adr	x0, eloutput
	lsl	x1, x27, #3 /* x2 - address for reading */
	add	x1, x1, x24
    ldr d0, [x1]
	bl	printf
    add x27, x27, #1
    add x26, x26, #1
    cmp x26, x25
    bge 1f
    b   0b
1:
    /* It's time for \n! */
    mov x26, #0
    adr x0, newline
    bl  printf
    b   0b
2:
    ldp x29, x30, [sp], #16
    ret
    .size print_matrix, .-print_matrix

