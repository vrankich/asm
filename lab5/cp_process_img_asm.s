    .arch   armv8-a
    .text
    .align  2
    .global rotate_image_asm
    .type   rotate_image_asm, %function
    /* d0 - angle
     * x0 - image
     * x1 - new image
     * x2 - height
     * x3 - width
     * x4 - channels
     * x5 - new height
     * x6 - new width */
rotate_image_asm:
    stp     x29, x30, [sp, #-16]!
    fmov    d10, d0
    mov     x20, x0
    mov     x21, x1
    mov     x22, x2
    mov     x23, x3
    mov     x24, x4
    mov     x25, x5
    mov     x26, x6
    mul     x28, x26, x24 /* x28 = new_width * channels */

    fmov    d13, d0

    fmov d0, d13
    bl  sin
    fmov d12, d0 /* d22 = sin(angle) */

    /* Count cos(angle) and sin(angle) */
    fmov d0, d13
    bl  cos
    fmov d11, d0 /* d21 = cos(angle) */
    mov x0, #2
    sdiv    x18, x22, x0 /* x18 = x_center */
    sdiv    x19, x23, x0 /* x19 = y_center */
    mov x15, #-1 /* x15 = x */
i:
    add x15, x15, #1
    cmp x15, x25
    bge end
    sub x13, x15, x18 /* x13 = xt */
    mov x16, #0 /* x16 = y */
    b   aaa
j:
    add x16, x16, #3
aaa:
    cmp x16, x28
    bge i
    sdiv    x14, x16, x24 /* y / channels */
    sub x14, x14, x19 /* x14 = yt */
    scvtf   d0, x13
    scvtf   d1, x14
    fmul    d2, d1, d12 /* yt*sin(angle) */
    fmul    d3, d0, d11 /* xt*cos(angle) */
    fsub    d3, d3, d2

    mov x10, #0
    fcvtzs    x10, d3
    add x11, x10, x18 /* x11 = x_rotate */
    fmul    d2, d1, d11 /* yt*cos(angle) */
    fmul    d3, d0, d12 /* xt*sin(angle) */
    fadd    d3, d3, d2
    mov x10, #0
    fcvtzs    x10, d3
    add x12, x10, x19 /* x12 = y_rotate */


    cmp x11, #0
    blt j
    cmp x11, x22
    bge j

    cmp x12, #0
    blt j
    cmp x12, x23
    bge j

    mov x0, #2
    /* Calculate coordinate in new image to x10 */
    sdiv    x1, x26, x0
    add     x1, x1, x14
    mul     x1, x1, x24
    sdiv    x2, x24, x0
    add     x2, x2, x13
    mul     x2, x2, x26
    mul     x2, x2, x24
    add     x10, x1, x2
    /* Calculate coordinate in old image to x9 */
    mul     x1, x12, x24
    mul     x2, x11, x23
    mul     x2, x2, x24
    add   x9, x1, x2

    /* pixel dance  */
    ldrb    w0, [x20, x9]
    strb    w0, [x21, x10]
    add     x9, x9, #1
    add     x10, x10, #1
    ldrb    w0, [x20, x9]
    strb    w0, [x21, x10]
    add     x9, x9, #1
    add     x10, x10, #1
    ldrb    w0, [x20, x9]
    strb    w0, [x21, x10]

    b   j
end:
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret
    .size   rotate_image_asm, .-rotate_image_asm
