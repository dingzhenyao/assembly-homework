; tsr.com - 按 = 键激活，然后按 1~7 生成 player.bat
; 内容: @echo off
;        call host_play.bat MUSIC\SONG0x.MP3  (x=按下的数字)

.model tiny
.code
org 100h

start:
    jmp install

; 状态标志：0=正常, 1=已按=键等待数字
activated db 0

; 新 INT 16h 处理程序
new_int16:
    cmp ah, 0
    je  process_key
    cmp ah, 10h
    je  process_key
    jmp dword ptr cs:[old_int16]

process_key:
    pushf
    call dword ptr cs:[old_int16]   ; 获取键信息到AX

    push ax
    push bx
    push dx
    push ds
    push es

    push cs
    pop ds                          ; DS = CS

    ; 检查是否已激活
    cmp activated, 1
    je  check_digit_1to7

    ; 未激活：检查是否按下 = 键
    cmp ah, 0Dh                     ; 扫描码 0Dh = 等号键
    jne not_hotkey
    cmp al, '='
    jne not_hotkey

    mov activated, 1                 ; 激活状态
    jmp exit_handler

check_digit_1to7:
    ; 检查是否是 '1' ~ '7'
    cmp al, '1'
    jb  reset_state
    cmp al, '7'
    ja  reset_state

    ; 是 1~7！准备生成 player.bat
    ; 先构造内容：固定部分 + 数字 + 固定后缀

    ; message 模板: "@echo off\r\ncall host_play.bat MUSIC\SONG0X.MP3\r\n"
    ; X 位置是第 41 字节（从0开始计数）
    mov bx, offset message
    add bx, 41                      ; 指向 'X' 的位置
    mov [bx], al                    ; 把按下的数字填进去

    ; 创建文件 player.bat
    mov ah, 3Ch
    mov cx, 0                       ; 普通属性
    mov dx, offset filename
    int 21h
    jc  create_failed
    mov bx, ax                      ; 文件句柄

    ; 写文件（总长度 41 字节，包括两个回车换行）
    mov ah, 40h
    mov cx, msglen
    mov dx, offset message
    int 21h

    ; 关闭文件
    mov ah, 3Eh
    int 21h

create_failed:
    mov activated, 0                ; 无论如何都重置状态
    jmp exit_handler

reset_state:
    mov activated, 0                 ; 非1-7数字，取消激活

not_hotkey:
exit_handler:
    pop es
    pop ds
    pop dx
    pop bx
    pop ax
    iret

; 文件名
filename  db 'player.bat',0

; 文件内容模板（X 会被替换成实际数字）
message   db '@echo off',0Dh,0Ah
          db 'call host_play.bat MUSIC\SONG0X.MP3',0Dh,0Ah
msglen    equ $ - message          ; 固定长度 41 字节

old_int16 dd ?

install:
    mov ax, 3516h
    int 21h
    mov word ptr old_int16, bx
    mov word ptr old_int16+2, es

    mov ax, 2516h
    mov dx, offset new_int16
    int 21h

    mov ah, 09h
    mov dx, offset msg_installed
    int 21h

    ; 驻留
    mov dx, offset install
    add dx, 15
    mov cl, 4
    shr dx, cl
    inc dx
    mov ax, 3100h
    int 21h

msg_installed db 'TSR installed: Press = then 1-7 to create player.bat for SONG01~07',0Dh,0Ah,'$'

end start