    .arch armv8-a

/* Sort rows of matrix my min elements
 * gnome sort */

    .data
    .align  2
n:
    .word   5 /* number of rows */
m:
    .word   6 /* number of columns */
matrix:
    .hword  12, 4, 3, 5, 2, 1
    .hword  8, 7, 15, 2, 3, 0
    .hword  10, 2, 3, 2, 6, 5
    .hword  9, 9, 9, 9, 9, 9
    .hword  0, 0, 5, 0, -1, 2
res:
    .skip   5*6*2 /* n x m x 2 */
mins:
    .skip   5*2 /* n x 2 bytes (hword)  */
indexes:
    .skip   5*2
    /* code segment */
    .text
    .align  2
    .global _start
    .type   _start, %function
_start:
    adr     x2, n
    ldrh    w0, [x2]    /* w0 - number of rows */
    adr     x2, m
    ldrh    w1, [x2]    /* w1 - number of columns */
    adr     x2, matrix  /* beginning of the matrix */
    adr     x12, res    /* beginning of the new matrix (result) */
    adr     x3, mins    /* beginning of the array mins */
    adr     x13, indexes
    mov     w4, #0 /* number of column of element */
    mov     w5, #0 /* counter of rows */
    mov     x6, #0 /* counter of elements */
    ldrh    w7, [x2] /* w7 - first element */
INDEXES:
    /* form array of indexes of rows */
    cmp     w4, w0
    bge     L
    uxth    x6, w4
    strh    w4, [x13, x6, lsl #1]
    add     w4, w4, #1
    b       INDEXES
L:
    mov     w4, #0
    mov     x6, #0
L0:
    add     w4, w4, #1
    cmp     w4, w1
    bge     L2
    add     x6, x6, #1
    ldrsh   w8, [x2, x6, lsl #1]
    cmp     w7, w8
    ble     L0
    mov     w7, w8
    b L0
L1:
    cmp     w5, w0
    bge     L3
    mov     w4, #0
    /* w7 - first element of the next row */
    ldrsh    w7, [x2, x6, lsl #1]
    b       L0
L2:
    /* new min element -> w7
     * x3 - beginning of the array mins
     * x4 - last processed row */
    sxth    x15, w5
    strh    w7, [x3, x15, lsl #1]
    add     x6, x6, #1 /* next element */
    add     w5, w5, #1 /* next row */
    b       L1
L3:
    /* formed array mins -> sort */
    mov     w4, #1 /* x4 - index of mins[i] */
    mov     w5, #2 /* j */
L4:
    cmp     w4, w0
    bge     exit
    sub     w6, w4, #1 /* w6 = i - 1 */
    sxth    x14, w4
    sxth    x16, w6
    ldrsh    w7, [x3, x14, lsl #1] // w15 - arr[i]
    ldrsh    w8, [x3, x16, lsl #1] // w16 - arr[i-1]
    cmp     w8, w7 /* mins[i-1] - mins[i] */
//.ifdef reverse
    ble     L5
//.else
//    bge     L5
//.endif
    /* if (mins[i-1] > mins[i]) swap rows i and i-1 */
    strh    w8, [x3, x14, lsl #1]
    strh    w7, [x3, x16, lsl #1]
    mov     w10, #0
    /* get addresses of rows x4 and x6 */
    umull   x14, w1, w4 /* x14 = m * w4 */
    umull   x16, w1, w6 /* x16 = m * w6 */
    add     x11, x2, x14, lsl #1 /* x4 -> x11 */
    add     x12, x2, x16, lsl #1 /* x6 -> x12 */
    b       L6
L5:
    mov     w4, w5
    add     w5, w5, #1
    b       L4
L6:
    /* swap rows x4 and x6 */
    cmp     w10, w1
    bge     L7
    ldrsh   w17, [x2, x14, lsl #1]
    ldrsh   w18, [x2, x16, lsl #1]
    strh    w18, [x2, x14, lsl #1]
    strh    w17, [x2, x16, lsl #1]
    add     x14, x14, #1
    add     x16, x16, #1
    add     x10, x10, #1
    b       L6
L7:
    subs    w4, w4, #1
    beq     L5
    b       L4
exit:
    mov     x0, #0
    mov     x20, #93
    svc     #0
    .size   _start, .-_start

