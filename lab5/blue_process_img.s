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
    //stp     x29, x30, [sp, #-16]!
    mov     x19, x30
    fmov    d10, d0
    mov     x20, x0
    mov     x21, x1
    mov     x22, x2
    mov     x23, x3
    mov     x24, x4
    mov     x25, x5
    mov     x26, x6
    mul     x27, x26, x24 /* x27 = new_width * channels */
0:
    mov     w0, #0
    mov     w1, #0
    mov     w2, #225

    mul     x27, x27, x25
    mov     x28, #0
1:
    cmp     x28, x27
    bge     end
    strb    w0, [x21, x28]
    add     x28, x28, #1
    strb    w1, [x21, x28]
    add     x28, x28, #1
    strb    w2, [x21, x28]
    add     x28, x28, #1
    b       1b
end:
    mov x0, #0
    //ldp x29, x30, [sp], #16
    mov x30, x19
    ret
    .size   rotate_image_asm, .-rotate_image_asm
