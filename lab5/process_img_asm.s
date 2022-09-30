    .arch   armv8-a
    .text
    .align  2
    .global rotate_asm
    .type   rotate_asm, %function
rotate_asm:
    stp     x29, x30, [sp, #-16]!

    /*
     *  d0 - sin
     *  d1 - cos
     *  x0 - old img
     *  x1 - new img
     *  x2 - w
     *  x3 - h
     *  x4 - res w
     *  x5 - res h
     */

    /*
     *  x6 - x_center
     *  x7 - y_center
     *  x8 - res_x_center
     *  x9 - res_y_center
     *  x10 - x_res
     *  x11 - y_res
     *  x12 - x
     *  x13 - y
     *  x14 - i_res
     *  x15 - i
     *  x16 - pixel
     *  x17 - harlot #1
     *  x18 - harlot #2
     */

    mov     x18, #2
    sdiv    x6, x2, x18
    sdiv    x7, x3, x18
    sdiv    x8, x4, x18
    sdiv    x9, x5, x18

    mov     x11, #-1
0:
    add     x11, x11, #1
    cmp     x11, x5
    bge     end
    mov     x10, #-1
1:
    add     x10, x10, #1
    cmp     x10, x4
    bge     0b

    /* Round towards zero */
    mov     x18, #0x11
    mrs     x18, FPCR

    sub     x18, x10, x8
    scvtf   d2, x18         /* d2 = x_res - res_x_center */
    sub     x18, x11, x9
    scvtf   d3, x18         /* d3 = y_res - res_y_center */

    fmul    d4, d2, d1
    fmul    d5, d3, d0
    fsub    d6, d4, d5
    fcvtzs  x12, d6

    fmul    d4, d3, d1
    fmul    d5, d2, d0
    fadd    d6, d4, d5
    fcvtzs  x13, d6

    neg     x18, x6
    cmp     x12, x18
    blt     1b

    cmp     x12, x6
    bge     1b

    neg     x18, x7
    cmp     x13, x18
    blt     1b

    cmp     x13, x7
    bge     1b

    mov     x18, #3
    mul     x14, x4, x11
    add     x14, x14, x10
    mul     x14, x14, x18

    add     x15, x7, x13
    mul     x15, x15, x2
    add     x17, x6, x12
    add     x15, x15, x17
    mul     x15, x15, x18

    ldrb    w16, [x0, x15]
    strb    w16, [x1, x14]
    add     x14, x14, #1
    add     x15, x15, #1
    ldrb    w16, [x0, x15]
    strb    w16, [x1, x14]
    add     x14, x14, #1
    add     x15, x15, #1
    ldrb    w16, [x0, x15]
    strb    w16, [x1, x14]
    b       0b
end:
    ldp     x29, x30, [sp], #16
    mov     x0, #0
    ret
    .size   rotate_asm, .-rotate_asm
