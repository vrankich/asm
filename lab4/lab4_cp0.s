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
    /* Read n*n numbers */
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
    /* Read matrix */
	ldr	x0, [x29, filestruct]
	adr	x1, formdouble
	lsl	x2, x27, #3 /* x2 - address for reading */
	add	x2, x2, x29 /* x29 - beginning of the stack frame */
	add	x2, x2, matrixA
	bl	fscanf
	cmp	w0, #1 /* Is one element read? */
	beq	5f
	ldr	x0, [x29, filestruct]
	bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, format
	bl	fprintf
	b	9b
5:
	add	x27, x27, #1
	cmp	x27, x28
	bne	4b
    mov x27, #0
6:
    /* Read matrix B */
	ldr	x0, [x29, filestruct]
	adr	x1, formdouble
	lsl	x2, x27, #3 /* x2 - address for reading */
	add	x2, x2, x29 /* x29 - beginning of the stack frame */
	add	x2, x2, matrixB
	bl	fscanf
	cmp	w0, #1 /* Is one element read? */
	beq	7f
	ldr	x0, [x29, filestruct]
	bl	fclose
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, format
	bl	fprintf
	b	9b
7:
	add	x27, x27, #1
	cmp	x27, x28
	bne	6b
    /* Matrix is read -> close file */
	ldr	x0, [x29, filestruct]
	bl	fclose
	mov	x1, #0
	ldr	x28, [x29, n]
8:
    mov x27, #0
    mov x26, #0
    ldr x25, [x29, n]
    mul x28, x28, x28
//    adr x0, resmes
//    bl  printf
9:
    cmp x27, x28
    bge 1f

	lsl	x1, x27, #3 /* x2 - address for reading */
	add	x1, x1, x29
    add x2, x1, matrixA
    ldr d0, [x2]
    add x3, x1, matrixB
    ldr d1, [x3]
    fadd    d2, d1, d0
    mov x5, res
    add x4, x1, x5
    //add x4, x1, matrixB
    str d2, [x4]

    /* Print matrix A */
//	adr	x0, eloutput
//	lsl	x1, x27, #3 /* x2 - address for reading */
//	add	x1, x1, x29
//    add x1, x1, matrixA
//    ldr d0, [x1]
//	bl	printf
//
    add x27, x27, #1
//    add x26, x26, #1
//    cmp x26, x25
//    bge 0f
    b   9b
1:
//    mov x27, #0
//    mov x26, #0
    //ldr x25, [x29, n]
    //mul x28, x28, x28
    adr x0, resmes
    bl  printf
    ldr w0, [x29, n]
    mov x2, res
    add x1, x29, x2
    bl  print_matrix
//2:
//    cmp x27, x28
//    bge 4f
//
//	adr	x0, eloutput
//	lsl	x1, x27, #3 /* x2 - address for reading */
//	add	x1, x1, x29
//    mov x2, res
//    add x1, x1, x2
//    ldr d0, [x1]
//	bl	printf
//
//    add x27, x27, #1
//    add x26, x26, #1
//    cmp x26, x25
//    bge 3f
//    b   2b
//3:
//    /* It's time for \n! */
//    mov x26, #0
//    adr x0, newline
//    bl  printf
//    b   2b
4:
	mov	w0, #0
	ldp	x29, x30, [sp]
	ldp	x27, x28, [sp, #16]
    mov x26, #9664
	add	sp, sp, x26
	ret
	.size	main, .-main

    .global print_matrix
    .type   print_matrix, %function
print_matrix:
    /* x0 - n
     * x1 - matrix */
    mul x28, x0, x0 /* x28 - n*n */
    mov x25, x0 /* x0 - n */
    mov x29, x1 /* x29 - matrix */
    mov x27, #0
    mov x26, #0
0:
    cmp x27, x28
    bge 2f
	adr	x0, eloutput
	lsl	x1, x27, #3 /* x2 - address for reading */
	add	x1, x1, x29
    //add x1, x1, matrix
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
    ret
    .size print_matrix, .-print_matrix

