	.arch armv8-a

	/* res = (a*b*c - c*d*e) / (a/b + c/d) */

	/* Data segment
	 * unsigned data */
	.data
	.align	3
res:
	.skip	8 // reserve 8 bytes
a:	.word	275
d:	.word   1000
b:	.hword	2
c:	.hword	9
e:	.hword	11
    /* Code segment */
	.text
	.align	2
	.global	_start
	.type	_start, %function
_start:
	adr	x0, a
	ldr	w1, [x0]
	adr	x0, b
	ldrh	w2, [x0]
	adr	x0, c
	ldrh    w3, [x0]
	adr	x0, d
	ldr	x4, [x0]
	adr	x0, e
	ldrh    w5, [x0]
	umull	x6, w1, w2 // a*b
    uxtw    x0, w3
	mul	x7, x6, x0 // x7 = a*b*c
	umull     x8, w4, w3 // c*d
	mul	x9, x8, x5 // x9 = c*d*e
	subs	x10, x7, x9
	bmi     EXIT_CRASH
	cmp w2, #0 // b == 0
    beq EXIT_CRASH
    udiv	w6, w1, w2 // w6 = a/b
	cmp w4, #0 // d == 0
    beq EXIT_CRASH
    udiv	w8, w3, w4 // w8 = c/d
	adds	x11, x8, w6, uxth // (a/b + c/d)
	bcs     EXIT_CRASH
	beq     EXIT_CRASH
	udiv	x12, x10, x11 // x12 = res
	adr	x0, res
	str	x12, [x0]
EXIT:
	mov	x0, #0
    b FULL_EXIT
EXIT_CRASH:
    mov x0, #1
FULL_EXIT:
	mov	x8, #93
	svc	#0
    .size	_start, .-_start
