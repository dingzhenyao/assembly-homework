; zhongduan.asm - 在 MASM 下演示 INTO（INT 4）溢出处理
; 要点：保存原 IVT，安装自定义 INT4 处理程序（输出错误），触发 INTO，恢复原 IVT 并退出
; 仅在实模式 / DOS 环境下有效（使用 IVT、int 21h、iret）

.model small
.stack 100h
.data
    old_off dw 0
    old_seg dw 0
    msg_overflow db 'error!overflow$'
.code
start:
    mov ax, @data
    mov ds, ax

    ; 保存原来 INT4 向量（偏移/段）
    xor ax, ax
    mov es, ax              ; ES = 0 -> 指向 IVT
    mov ax, word ptr es:[10h]
    mov [old_off], ax
    mov ax, word ptr es:[12h]
    mov [old_seg], ax

    ; 安装新的 INT4 处理程序（into_handler），写入 IVT
    cli
    xor ax, ax
    mov es, ax
    mov word ptr es:[10h], OFFSET into_handler
    mov word ptr es:[12h], SEG into_handler
    sti

    ; 演示：触发有符号溢出（32767 + 1）并使用 INTO 触发中断
    mov ax, 32767
    mov bx, 1
    add ax, bx
    into                    ; 若 OF=1，CPU 会触发 INT 4 -> into_handler

    ; 恢复原来 INT4 向量
    cli
    xor ax, ax
    mov es, ax
    mov ax, [old_off]
    mov word ptr es:[10h], ax
    mov ax, [old_seg]
    mov word ptr es:[12h], ax
    sti

    ; 退出到 DOS
    mov ah, 4ch
    xor al, al
    int 21h

; ------------------
; INT4 服务例程：保存寄存器、切换到数据段输出字符串、恢复寄存器、IRET
; 说明：不要额外 pushf/popf（CPU 已经在中断入口保存了 FLAGS/IP/CS），
;       这里保存常用寄存器以免破坏主程序状态
; ------------------
into_handler proc far
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es

    push ds                ; 保存 DS（因为我们要更改 DS 指向数据段）
    mov ax, SEG msg_overflow
    mov ds, ax             ; DS = 数据段，保证 int21 输出时 DS:DX 有效

    mov ah, 09h            ; DOS 显示以 '$' 结尾的字符串
    lea dx, msg_overflow
    int 21h

    pop ds                 ; 恢复 DS
    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret
into_handler endp

end start
