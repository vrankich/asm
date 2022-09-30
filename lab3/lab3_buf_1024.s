	.arch armv8-a

/* Circular shift of words by N symbols to right */

    .data
mes_N:
    .string "Enter N: "
    .equ    len_N, .-mes_N
mes1:
    .string "Filename for result: "
    .equ    len1, .-mes1
mes2:
	.string	"Enter string: "
	.equ	len2, .-mes2
mes3:
    .string "File exists. Rewrite (y/n)? "
    .equ    len3, .-mes3
mes_err:
    .string "Something went wrong. Sorry...\n"
    .equ    len_err, .-mes_err
choice:
    .skip   3
N:
    .skip   3
str:
	.skip	1024
filename:
    .skip   1024
mes_res:
	.ascii  "'"
newstr:
	.skip	1024
    .align  3
fd:
    .skip   8

    .text
	.align	2
	.global _start
	.type	_start, %function
_start:
    /* #1 - file descriptor number for stdin */
	mov	    x0, #1
    adr 	x1, mes_N
	mov 	x2, len_N
	mov 	x8, #64
	svc 	#0
    /* Read N */
	mov 	x0, #0
	adr 	x1, N
	mov 	x2, #1023
	mov 	x8, #63
	svc 	#0
	cmp 	x0, #1 /* at least enter */
	//ble 	L11
	ble     exit
    adr 	x1, N
    /* Delete \n */
    sub 	x0, x0, #1
    strb	wzr, [x1, x0] /* wzr - NULL register */
    ldrb    w20, [x1]
    mov     w10, '0'
    sub     w20, w20, w10

    /* Read filename */
    mov     x0, #1
    adr     x1, mes1
    mov     x2, len1
    mov     x8, #64
    svc     #0
    mov     x0, #0
    adr     x1, filename
    mov     x2, #1024
    mov     x8, #63
    svc     #0
    cmp     x0, #1
    ble     bad_exit

    sub     x2, x0, #1
    mov     x0, #-100
    adr     x1, filename
    strb    wzr, [x1, x2]
    mov     x2, #0xc1
    mov     x3, #0600
    mov     x8, #56
    svc     #0
    cmp     x0, #0
    bge     save_fd
    cmp     x0, #-17
    bne     bad_exit
    /* Ask for rewriting the file */
    mov     x0, #1
    adr     x1, mes3
    mov     x2, len3
    mov     x8, #64
    svc     #0
    mov     x0, #0
    adr     x1, choice
    mov     x2, #3
    mov     x8, #63
    svc     #0
    cmp     x0, #2
    beq     read_answer
	b   	bad_exit
read_answer:
    /* Input answer */
    adr     x1, choice
    ldrb    w0, [x1]
    cmp     w0, 'Y'
    beq     answer_yes
    cmp     w0, 'y'
    beq     answer_yes
    mov     x0, #-17
    b       exit
answer_yes:
    /* Rewrite file */
    mov     x0, #-100
    adr     x1, filename
    mov     x2, #0x201
    mov     x8, #56
    svc     #0
    cmp     x0, #0
    blt     bad_exit
save_fd:
    adr     x1, fd
    str     x0, [x1]
smile:
    /* Ask for string */
    mov	    x0, #1
    adr 	x1, mes2
	mov 	x2, len2
	mov 	x8, #64
	svc 	#0
    /* Input string */
	mov 	x0, #0
	adr 	x1, str
	mov 	x2, #1023
	mov 	x8, #63
	svc 	#0
    /* x0 - length of str */
	cmp 	x0, #0
	ble 	L11
	adr 	x1, str
    /* Delete \n from str */
    sub 	x0, x0, #1
    strb	wzr, [x1, x0] /* wzr - NULL register */
    /* x3, x4 -> newstr */
	adr 	x3, newstr
	mov 	x4, x3
L0:
	ldrb	w0, [x1], #1
	cbz 	w0, L9  /* end of the str */
	cmp 	w0, ' ' /* end of the word */
	beq 	L0      /* skip spaces */
    cmp     w0, '\t'
    beq     L0
    cmp 	x4, x3
	beq 	L1
    /* not first word -> write space to newstr */
	mov	    w0, ' '
	strb	w0, [x3], #1
//    add     x15, x15, #1
    b       L1
L1:
    /* x2 - beginning of the word */
	sub 	x2, x1, #1
	mov     x12, #0 /* x10 - counter of chars in word */
L2:
    /* Read next symbol in word */
	ldrb	w0, [x1], #1
	add     x12, x12, #1
    cbz	    w0, L3
	cmp	    w0, ' '
	beq	    L3
	cmp	    w0, '\t'
	bne	    L2
L3:
    /* x5 - next symbol after the word */
	sub	    x5, x1, #1
    sub     x12, x12, #1
    mov     w21, #0
L4:
    cmp     w21, w20 /* compare with N */
    bge     L7
    add     w21, w21, #1
	mov     x6, x5
    ldrb    w7, [x6, #-1]! /* remember last char */
    mov     x10, x12
L5:
    cmp     x10, #0
    ble     L6
	ldrb	w0, [x6, #-1]! /* preindex addressing */
	strb    w0, [x2, x10, lsl #0]
//    add     x15, x15, #1
    sub     x10, x10, #1
	cmp	    x6, x2
	bgt	    L5
    b       L6
L6:
    strb    w7, [x2]
    b   L4
L7:
    add     x12, x12, #1 /* add space */
	sub	    x1, x1, #1 /* last symbol */
    mov     x10, #0
L8:
    /* Write shifted word to newstr */
    cmp     x10, x12
    bge	    L0
    ldrb    w0, [x2, x10, lsl #0]
    strb    w0, [x3], #1
    add     x10, x10, #1
    b       L8
L9:
    /* Output newstr */
    mov	    w0, '\''
	strb	w0, [x3], #1
	mov	    w0, '\n'
	strb	w0, [x3], #1
//    add     x15, x15, #2
output:
    adr     x0, fd
    ldr     x0, [x0]
    adr     x1, newstr
    adr     x1, mes_res
	sub     x2, x3, x1
    mov 	x8, #64
	svc 	#0
	b   	smile
L11:
// ????????
adr     x0, fd
    ldr     x0, [x0]
    mov     x8, #57
    svc     #0
    b       exit
bad_exit:
    // add message !!!
exit:
    mov     x0, #0
	mov	    x8, #93
	svc	    #0
	.size	_start, .-_start
