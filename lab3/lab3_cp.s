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
        .align 2
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
        beq     error
        b       3f
error:
        mov     x0, #-3
        bl      writerr
        b       exit
3:
        adr     x1, N
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

    .type   left_offset, %function

left_offset:
        cmp     x0, #0
        bne     offset_ok
        mov     x0, x1
        b to_ret
offset_ok:
        mov     x17, #0
        mov     x3, x1
        mov     x4, x3
        mov     x14, #0
        sub     x15, x0, #1
        ldrb    w13, [x1, x15, lsl #0]
        cmp     w13, '\n'
        mov     x23, #-3
        strb    wzr, [x1, x15]
        bne     L0
        mov     x23, #3
        b       L0
L0:
        ldrb    w0, [x1], #1
        cbz     w0, L9
        cmp     w0, ' '
        beq     L0
        cmp     w0, '\t'
        beq     L0
        cmp     x4, x3
        beq     L1
        mov     w0, ' '
        strb    w0, [x3], #1
        b       L1
L1:
        adr     x20, N
        ldrb    w20, [x20]
        mov     w22, '0'
        sub     w20, w20, w22
        sub     x2, x1, #1
        mov     x17, #0
        b       L2
L2:
        ldrb    w0, [x1], #1
        add     x17, x17, #1
        cbz     w0, L3
        cmp     w0, ' '
        beq     L3
        cmp     w0, '\n'
        beq     L3
        cmp     w0, '\t'
        bne     L2
L3:
        sub     x17, x17, #1
        mov     w21, #0
L4:
        cmp     w21, w20
        bge     L7
        add     w21, w21, #1
        mov     x18, x2
        ldrb    w7, [x18, #0]!
        mov     x14, #0 //x17
L5:
        cmp     x14, x17 // index < len
        bgt     L6
        ldrb    w0, [x18, #1]!
        strb    w0, [x2, x14, lsl #0]
        add     x14, x14, #1
        cmp     x14, x17
        bgt     L6
        b       L5
L6:
        strb    w7, [x2, x17, lsl #0]
        b L4
L7:
        add     x17, x17, #1
        sub     x1, x1, #1
        mov     x14, #0
L8:
        cmp     x14, x17
        bge     L0
        ldrb    w0, [x2, x14, lsl #0]
        strb    w0, [x3], #1
        add     x14, x14, #1
        b       L8
L9:
        mov     x0, x4
        cmp     x23, #3
        beq     add_end
        bne     add_space
add_end:
        mov     w13, '\n'
        strb    w13, [x0, x15, lsl #0]
        b to_ret
add_space:
        mov     w13, ' '
        strb    w13, [x0, x15, lsl #0]
to_ret:
        ret
        .size   left_offset, .-left_offset

        .type   work, %function
        .equ    filename, 16
        .equ    fd, 24
        .equ    correct_result, 32
        .equ    buf, 40
work:
        mov     x16, #56 // buf_size = 16
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
        mov     x2, #16 // buffer
        mov     x8, #63
        svc     #0

        cmp     x0, #0
        beq     4f
        bgt     2f
        ldr     x0, [sp], #16
        bl      writerr
        b       3f

2:
        add     x0, x29, buf // buffer as an argument
        ldr     x1, [x29, fd]
        bl      string_processing
        /* Write string to file */
        str     x0, [x29, correct_result]
        add     x1, x29, buf
        bl      left_offset
        mov     x1, x0
        ldr     x2, [x29, correct_result]
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
        /* Close the file */
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

        .type   string_processing, %function
        .data
        .equ    buf_addr, 16
        .equ    fd_out, 24
        .equ    save_x2, 32
        .equ    save_x3,40
        .text
        .align      2
string_processing:
        sub     sp, sp, #56
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x0, [x29, buf_addr]
        str     x1, [x29, fd]

        mov     x1, x0 // uncorrected string
        mov     x2, x0 // corrected string
        mov     x10, #-1 // counter 2
        mov     x19, #0 // counter 1
        b       0f
skip_space:
        mov     x11, #0
0:
        ldrb    w3, [x1], #1
        add     x10, x10, #1
        add     x19, x19, #1
        cmp     x10, #16
        bge     string_more_than_buffer

        cmp     w3, ' '
        beq     0b
        cmp     w3, '\t'
        beq     0b
        cmp     w3, '\n'
        beq     end_of_line

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
        beq     string_more_than_buffer

        cmp     w3, ' '
        beq     5f
        cmp     w3, '\t'
        beq     5f

        b       4b
// write this word to the buffer
5:
        mov     x1, x6
6:
        ldrb    w3, [x1], #1
        cmp     w3, ' '
        beq     7f
        cmp     w3, '\t'
        beq     7f
        cmp     w3, '\n'
        beq     end_of_line

        strb    w3, [x2], #1
        b       6b
7:
        mov     w3, ' '
        strb    w3, [x2], #1
        b       skip_space

string_more_than_buffer:
        sub     x10, x1, x11
        /* Write string to the file */
        str     x3, [x29, save_x3]
        ldr     x1, [x29, buf_addr]
        sub     x0, x2, x1
        str     x0, [x29, save_x2]
        bl  left_offset
        mov     x1, x0
        ldr     x0, [x29, fd_out]
        ldr     x2, [x29, save_x2]
        mov     x8, #64
        svc     #0
        ldr     x3, [x29, save_x3]
// copy part of not whole data to the beginning
        mov     x12, #0
0:
        cmp     x11, x12
        beq     1f
        ldrb    w3, [x10], #1
        cmp     w3, #2
        beq     skip_stx
        add     x12, x12, #1
        strb    w3, [x1], #1
        b       0b
skip_stx:
        sub     x11, x11, #1
        b       0b
1:
// read new part of data
        mov     x0, #0
        mov     x2, #16
        sub     x2, x2, x11 // 16 - len
        mov     x8, #63
        svc     #0

        ldr     x1, [x29, buf_addr]
        ldr     x2, [x29, buf_addr]
        mov     x10, #-1 // hz
        b       skip_space
end_of_line:
        ldr     w3, [x2, #-1]!
        cmp     w3, ' '
        bne     all_ok
        sub     x2, x2, #1
all_ok:
        add     x2, x2, #1
        mov     w3, '\n'
        strb    w3, [x2], #1

        ldr     x0, [x29, buf_addr]
        sub     x0, x2, x0 // return size of buffer

        mov     sp, x29
        ldp     x29, x30, [sp]
        add     sp, sp, #56
        ret
        .size   string_processing, .-string_processing

        .type   writerr, %function
        .data
    nofile:
        .string "No such file or directory"
        .equ    nofilelen, .-nofile
    permission:
        .string "Permission denied"
        .equ    permissionlen, .-permission
    wrong_value:
        .string "Offset value must be from 1 to 9"
        .equ    wlen, .-wrong_value
    unknown:
        .string "Unknown error"
        .equ    unknownlen, .-unknown

        .text
        .align 2
writerr:
        cmp     x0, #-2
        bne     0f
        adr     x1, nofile
        mov     x2, nofilelen
        b       3f
0:
        cmp     x0, #-13
        bne     1f
        adr     x1, permission
        mov     x2, permissionlen
        b       3f
1:
        cmp     x0, #-3
        bne     2f
        adr     x1, wrong_value
        mov     x2, wlen
        b       3f
2:
        adr     x1, unknown
        mov     x2, unknownlen
3:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret

        .size   writerr, .-writerr
