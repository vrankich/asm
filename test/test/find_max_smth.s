    .arch   armv8-a
    .data
output:
    .string "Result: %d\n"
    .text
    .align  2
    .global main
    .type   main, %function
    .equ    nums, 32
main:
    // The next line is must have!
    sub sp, sp, #112 // 32 + 10*8

    // Manually fill data which is given in the test
    mov x0, #5
    mov x1, #27
    mov x2, #202
    mov x3, #-512
    mov x4, #-123
    mov x5, #133


    // Starting point for program in the test
    mov x11, #0
    str x1, [sp, x11, lsl #3]
    cmp x0, #1
    beq one_num
    add x11, x11, #1
    str x2, [sp, x11, lsl #3]
    cmp x0, #2
    beq work
    add x11, x11, #1
    str x3, [sp, x11, lsl #3]
    cmp x0, #3
    beq work
    add x11, x11, #1
    str x4, [sp, x11, lsl #3]
    cmp x0, #4
    beq work
    add x11, x11, #1
    str x5, [sp, x11, lsl #3]
    cmp x0, #5
    beq work
    add x11, x11, #1
    str x6, [sp, x11, lsl #3]
    cmp x0, #6
    beq work
    add x11, x11, #1
    str x7, [sp, x11, lsl #3]
    cmp x0, #7
    beq work
    add x11, x11, #1
    str x8, [sp, x11, lsl #3]
    cmp x0, #8
    beq work
    add x11, x11, #1
    str x9, [sp, x11, lsl #3]
    cmp x0, #9
    beq work
    add x11, x11, #1
    str x10, [sp, x11, lsl #3]
    cmp x0, #10
    beq work
work:
    /* x11, x12 - counters
     * x13, x14 - numbers to check in the cycle
     * x1 - max sum of needed abs
     * x2 - max number of equal digits
     */
    mov x11, #-1
    mov x2, #-1
0:
    add x11, x11, #1
    cmp x11, x0
    bge end
    mov x12, #-1
    ldr x13, [sp, x11, lsl #3]
    cmp x13, #0
    cneg    x13, x13, lt
1:
    add x12, x12, #1
    cmp x12, x0
    bge 0b

    /* Don't check equal numbers */
    cmp x12, x11
    beq 1b

    ldr x14, [sp, x12, lsl #3]
    cmp x14, #0
    cneg    x14, x14, lt

    mov x15, x13
    mov x16, x14
    mov x3, #0
    mov x10, #10
2:
    /* Count equal digits
     * x15, x16 - devided numbers from the last cycle
     * x17, x18 - digits to compare
     * x3 - counter of equal digits
     */
    cmp x15, #0
    beq 4f
    cmp x16, #0
    beq 4f
    udiv    x19, x15, x10
    mul     x19, x19, x10
    sub     x17, x15, x19
    udiv    x19, x16, x10
    mul     x19, x19, x10
    sub     x18, x16, x19
    cmp     x17, x18
    bne     3f
    add     x3, x3, #1
3:
    udiv    x15, x15, x10
    udiv    x16, x16, x10
    b   2b
4:
    cmp x3, x2
    blt 1b
    add x19, x13, x14
    cmp x3, x2
    bne 5f
    /* Check sums */
    cmp x19, x1
    ble 1b
5:
    /* New max number of equal digits */
    mov x1, x19
    mov x2, x3
    b   1b
one_num:
    mov x0, #0
    b   end
end:
    // SAVE STACK BEFORE OUTPUT
    stp x29, x30, [sp]

    /* x1 - result */
    adr x0, output
    bl  printf

    ldp x29, x30, [sp]
    add sp, sp, #112
    ret
    .size   main, .-main

