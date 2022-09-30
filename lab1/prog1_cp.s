	.arch armv8-a

	/* res = (a*b*c - c*d*e) / (a/b + c/d) */

	/* Data segment
	 * unsigned data */
	.data
	.align	3
res:
    .skip	8
b:  .hword	2
c:	.hword	9
e:	.hword	11
a:	.word	275
d:	.word	202
//v:  .quad   9090909090909
//r:  .quad   8989898989899
    /* Code segment */
	.text
	.align	2 // 32-bit commands
	.global	_start // mark for the beginning of the program (first command)
	.type	_start, %function // mark type
_start:
	adr	x0, a
	ldr    w1, [x0]
	adr	x0, b
    ldrh    w2, [x0]
	adr x0, c // trash num
	//ldr	x3, [x0]
	ldrh     w3, [x0]
    adr	x0, d
	//adr     x0, v
    ldr	x4, [x0]
    adr	x0, e // trash num
	//adr     x0, r
    //ldr	x5, [x0]
	ldrh    w5, [x0]
    /* (a*b*c - c*d*e) */
	umull	x6, w1, w2 // x6 =  a * b
	umull	x7, w3, w6
	//mul   x7, x3, x6
    //mul	x8, x3, x4 // x8 = c * d
	umull     x8, w4, w3
    mul	x9, x8, x5 // x9 = c * d * e
	subs	x10, x7, x9
	bmi     EXIT
    //bcs     EXIT
    /* (a/b + c/d) */
	udiv	w6, w1, w2 // w6 = a / b
	udiv	w8, w3, w4 // w8 = c / d
	adds	x11, x8, w6, uxth
	//adds    x11, w8, w6
    bcs     EXIT
    beq     EXIT
    /* res */
	udiv	x12, x10, x11
    adr	x0, res
    str	x12, [x0]
    /* System calls */
EXIT:
    mov	x0, #0
	mov	x8, #93
	svc	#0 // call supervisor

	.size	_start, .-_start

