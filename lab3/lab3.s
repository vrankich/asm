        .arch   armv8-a
        .data
mes_N:
        .string "Enter N: "
        .equ    len_N, .-mes_N
mes2:
        .string "Enter string: "
        .equ    len2, .-mes2
errmes1:
        .string "Usage: "
        .equ    errlen1, .-errmes1
errmes2:
        .string " filename\n"
        .equ    errlen2, .-errmes2
newline:
        .string "\n"
        .equ    len_nl, .-newline
N:
        .skip   8
        .text
        .align  2
        .global _start
        .type   _start, %function
_start:
        ldr     x0, [sp]
        cmp     x0, #2
        beq     2f
        mov     x0, #2
        adr     x1, errmes1
        mov     x2, errlen1
        mov     x8, #64
        svc     #0
        mov     x0, #2
        ldr     x1, [sp, #8]
        mov     x2, #0
0:
        ldrb    w3, [x1, x2]
        cbz     w3, 1f
        add     x2, x2, #1
        b       0b
1:
        mov     x8, #64
        svc     #0
        mov     x0, #2
        adr     x1, errmes2
        mov     x2, errlen2
        mov     x8, #64
        svc     #0
        mov     x0, #-1
        b       exit
2:
        /* Read N */
        mov     x0, #1
        adr     x1, mes_N
        mov     x2, len_N
        mov     x8, #64
        svc     #0
        mov     x0, #0
        adr     x1, N
        mov     x2, len_N
        mov     x8, #63
        svc     #0
        cmp     x0, #2
        beq     3f
error:
        mov     x0, #-3
        bl      writerr
        b       exit
3:
        adr     x1, N
        /* Delete \n */
        sub     x0, x0, #1
        strb    wzr, [x1, x0]
        ldrb    w20, [x1]
        mov     w10, '0'
        sub     w20, w20, w10
        cmp     w20, #0
        ble     error
        /* Load filename */
        ldr     x0, [sp, #16]
        bl work
exit:
        mov     x0, #1
        adr     x1, newline
        mov     x2, len_nl
        mov     x8, #64
        svc     #0
        mov     x8, #93
        svc     #0
        .size   _start, .-_start

        .type   smile, %function
smile:
        cmp     x0, #0
        bne     start
        mov     x0, x1
        b       end
start:
        mov     x17, #0
        mov     x3, x1
        mov     x4, x3
        mov     x10, #0
        sub     x15, x0, #1
        ldrb    w13, [x1, x15]
        cmp     w13, '\n'
        mov     x23, #-3
        strb    wzr, [x1, x15]
        bne     0f
        mov     x23, #3
        b       0f
0:
        ldrb    w0, [x1], #1
        cbz     w0, 9f  /* end of the string */
        cmp     w0, ' ' /* end of the word */
        beq     0b      /* skip spaces */
        cmp     w0, '\t'
        beq     0b      /* skip tabs */
        cmp     x4, x3
        beq     1f
        /* If the word is not first, write a space to new string */
        mov     w0, ' '
        strb    w0, [x3], #1
        b       1f
1:
        adr     x20, N
        ldrb    w20, [x20]
        mov     w22, '0'
        sub     w20, w20, w22
        /* x2 - beginning of the word */
        sub     x2, x1, #1
        /* x17 - counter of chars in the word */
        mov     x17, #0
2:
        /* Read next char in the word */
        ldrb    w0, [x1], #1
        add     x17, x17, #1
        cbz     w0, 3f
        cmp     w0, ' '
        beq     3f
        cmp     w0, '\n'
        beq     3f
        cmp     w0, '\t'
        bne     2b
3:
        /* x5 - next char after the word */
        sub     x5, x1, #1
        sub     x17, x17, #1
        mov     w21, #0
4:
        cmp     w21, w20 /* w20 - N */
        bge     7f
        add     w21, w21, #1
        mov     x18, x5
        ldrb    w7, [x18, #-1]! /* remember last char */
        mov     x10, x17
5:
        cmp     x10, #0
        ble     6f
        ldrb    w0, [x18, #-1]!
        strb    w0, [x2, x10, lsl #0]
        sub     x10, x10, #1
        cmp     x18, x2
        bgt     5b
        b       6f
6:
        strb    w7, [x2]
        b       4b
7:
        /* Add space */
        add     x17, x17, #1
        sub     x1, x1, #1
        mov     x10, #0
8:
        /* Write shifted word to new string */
        cmp     x10, x17
        bge     0b
        ldrb    w0, [x2, x10, lsl #0]
        strb    w0, [x3], #1
        add     x10, x10, #1
        b       8b
9:
        mov     x0, x4
        cmp     x23, #3
        beq     0f
        b       end
0:
        /* Add '\n' */
        mov     w13, '\n'
        strb    w13, [x3], #1
        b       end
end:
        ret
        .size   smile, .-smile

        .type   work, %function
        .equ    filename, 16
        .equ    fd, 24
        .equ    newstr, 32
        .equ    buf, 40
work:
        mov     x16, #56
        sub     sp, sp, x16
        stp     x29, x30, [sp]
        mov     x29, sp

        str     x0, [x29, filename]
        str     x1, [x29, N]
        /* Open file */
        mov     x1, x0
        mov     x0, #-100
        mov     x2, #0x201
        mov     x8, #56
        svc     #0

        cmp     x0, #0
        bge     0f
        bl      writerr
        b       4f
0:
        str     x0, [x29, fd]
1:
        mov     x0, #1
        adr     x1, mes2
        mov     x2, len2
        mov     x8, #64
        svc     #0
        /* Read string */
        mov     x0, #0
        add     x1, x29, buf
        mov     x2, #16 /* x2 - buffer */
        mov     x8, #63
        svc     #0
        cmp     x0, #0
        beq     4f
        bgt     2f
        ldr     x0, [sp], #16
        bl      writerr
        b       3f
2:
        add     x0, x29, buf
        ldr     x1, [x29, fd]
        bl      process_str
        /* Write string to file */
        str     x0, [x29, newstr]
        add     x1, x29, buf
        bl      smile

        mov     x1, x0
        ldr     x2, [x29, newstr]
        ldr     x0, [x29, fd]
        mov     x8, #64
        svc     #0
        b       1b
3:
        /* Error -> close the file */
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        mov     x0, #1
        b       5f
4:
        /* Just close the file */
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        mov     x0, #0
5:
        ldp     x29, x30, [sp]
        mov     x16, #56
        add     sp, sp, x16
        ret
        .size   work, .-work

        .type   process_str, %function
        .data
        .equ    buf, 16
        .equ    fd_out, 24
        .equ    reg_x2, 32
        .equ    reg_x3,40
        .text
        .align      2
process_str:
        sub     sp, sp, #56
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x0, [x29, buf]
        str     x1, [x29, fd]
        mov     x1, x0
        mov     x2, x0
        mov     x10, #-1
        mov     x19, #0
        b       0f
skip_space:
        mov     x11, #0
0:
        ldrb    w3, [x1], #1
        add     x10, x10, #1
        add     x19, x19, #1
        /* Compare str length to buf length */
        cmp     x10, #16
        bge     str_more_than_buffer
        cmp     w3, ' '
        beq     0b
        cmp     w3, '\t'
        beq     0b
        cmp     w3, '\n'
        beq     end_of_str
        sub     x1, x1, #1
        sub     x10, x10, #1
        sub     x19, x19, #1
        mov     x6, x1
4:
        ldrb    w3, [x1], #1
        add     x10, x10, #1
        add     x11, x11, #1

        mov     x12, #16
        cmp     w3, '\n'
        beq     5f
        cmp     x10, x12
        beq     str_more_than_buffer
        cmp     w3, ' '
        beq     5f
        cmp     w3, '\t'
        beq     5f
        b       4b
5:
        /* Write word to the buffer */
        mov     x1, x6
6:
        ldrb    w3, [x1], #1
        cmp     w3, ' '
        beq     7f
        cmp     w3, '\t'
        beq     7f
        cmp     w3, '\n'
        beq     end_of_str
        strb    w3, [x2], #1
        b       6b
7:
        mov     w3, ' '
        strb    w3, [x2], #1
        b       skip_space

str_more_than_buffer:
        sub     x10, x1, x11
        /* Write string to the file */
        str     x3, [x29, reg_x3]
        ldr     x1, [x29, buf]
        sub     x0, x2, x1
        str     x0, [x29, reg_x2]
        bl      smile
        mov     x1, x0
        ldr     x0, [x29, fd_out]
        ldr     x2, [x29, reg_x2]
        mov     x8, #64
        svc     #0
        ldr     x3, [x29, reg_x3]
        mov     x12, #0
0:
        cmp     x11, x12
        beq     2f
        ldrb    w3, [x10], #1
        cmp     w3, #2
        beq     1f
        add     x12, x12, #1
        strb    w3, [x1], #1
        b       0b
1:
        sub     x11, x11, #1
        b       0b
2:
        /* Read next part of data */
        mov     x0, #0
        mov     x2, #16
        sub     x2, x2, x11
        mov     x8, #63
        svc     #0

        ldr     x1, [x29, buf]
        ldr     x2, [x29, buf]
        mov     x10, #-1
        b       skip_space
end_of_str:
        ldr     w3, [x2, #-1]!
        cmp     w3, ' '
        bne     0f
        sub     x2, x2, #1
0:
        add     x2, x2, #1
        mov     w3, '\n'
        strb    w3, [x2], #1
        ldr     x0, [x29, buf]
        sub     x0, x2, x0
        mov     sp, x29
        ldp     x29, x30, [sp]
        add     sp, sp, #56
        ret
        .size   process_str, .-process_str

        .type   writerr, %function
        .data
    wrong_file:
        .string "No such file..."
        .equ    wfilelen, .-wrong_file
    wrong_value:
        .string "N should be a number between 1 and 9..."
        .equ    wlen, .-wrong_value
    unknown:
        .string "Error..."
        .equ    unknownlen, .-unknown

        .text
        .align 2
writerr:
        cmp     x0, #-2
        bne     0f
        adr     x1, wrong_file
        mov     x2, wfilelen
        b       2f
0:
        cmp     x0, #-3
        bne     1f
        adr     x1, wrong_value
        mov     x2, wlen
        b       2f
1:
        adr     x1, unknown
        mov     x2, unknownlen
2:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret

        .size   writerr, .-writerr
