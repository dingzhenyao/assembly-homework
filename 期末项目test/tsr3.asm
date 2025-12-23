; tsr.com - 按 = 键激活，然后按 1~7 生成 player.bat
; 内容: @echo off
;        call host_play.bat MUSIC\SONG0x.MP3  (x=按下的数字)
; 扩展: =9 生成 pause.bat (call host_play.bat pause)
;       =0 生成 quit.bat (call host_play.bat quit)
; 新功能: 连续按两次 = 键，卸载并退出驻留程序（恢复原INT 16h，释放内存）

.model tiny
.code
org 100h

start:
    jmp install

; 状态标志：0=正常, 1=已按=键等待数字或第二次=
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
    call dword ptr cs:[old_int16]   ; 调用原中断获取键信息到AX

    push ax
    push bx
    push cx
    push dx
    push ds
    push es

    push cs
    pop ds                          ; DS = CS

    ; 检查是否已激活（已按下 = 键）
    cmp activated, 1
    je  check_digit_or_double_eq

    ; 未激活：检查是否按下 = 键（扫描码 0Dh，ASCII '='）
    cmp ah, 0Dh
    jne not_hotkey
    cmp al, '='
    jne not_hotkey

    mov activated, 1                 ; 进入激活状态
    jmp exit_handler

check_digit_or_double_eq:
    ; 已激活，检查是否又是 = 键（连续两次 == 则卸载TSR）
    cmp ah, 0Dh
    jne not_double_eq
    cmp al, '='
    jne not_double_eq

    ; 连续两次 == ，执行卸载
    call uninstall_tsr
    jmp exit_handler                ; 卸载后直接返回（中断已恢复）

not_double_eq:
    ; 检查是否是数字 '0'~'9'
    cmp al, '0'
    jb  reset_state
    cmp al, '9'
    ja  reset_state

    cmp al, '9'
    je  do_pause
    cmp al, '0'
    je  do_quit

    ; 1~7 的范围检查
    cmp al, '1'
    jb  reset_state
    cmp al, '7'
    ja  reset_state

    ; ====== 播放歌曲 1~7 ======
    call generate_player
    jmp short done_create

do_pause:
    mov dx, offset filename_pause
    mov si, offset msg_pause
    mov cx, pause_msglen
    call create_file
    jmp short done_create

do_quit:
    mov dx, offset filename_quit
    mov si, offset msg_quit
    mov cx, quit_msglen
    call create_file
    ; 落入 done_create

done_create:
    mov activated, 0
    jmp exit_handler

reset_state:
    mov activated, 0                ; 非预期键，取消激活

not_hotkey:
exit_handler:
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    iret

; =============== 子程序：卸载 TSR ===============
uninstall_tsr:
    ; 1. 恢复原 INT 16h 中断向量
    mov ax, 2516h
    lds dx, dword ptr cs:[old_int16]
    int 21h

    ; 2. 释放程序内存块（COM 文件，PSP 在 CS）
    push cs
    pop es
    mov ah, 49h                     ; DOS 释放内存块
    int 21h
    ; 注意：释放后代码仍在执行，但内存已标记为空闲
    ; 后续不再返回此中断处理程序（因为向量已恢复）

    ret

; =============== 子程序：生成 player.bat（1~7）===============
generate_player:
    mov bx, offset message
    add bx, 41
    mov [bx], al

    mov dx, offset filename_player
    mov si, offset message
    mov cx, msglen
    ; 直接落入 create_file

; =============== 子程序：创建文件并写入内容 ===============
create_file:
    push cx

    mov ah, 3Ch
    xor cx, cx
    int 21h
    jc  create_failed

    mov bx, ax

    pop cx
    mov ah, 40h
    mov dx, si
    int 21h

    mov ah, 3Eh
    int 21h

create_failed:
    ret

; =============== 数据区 ===============
filename_player db 'player.bat',0
filename_pause  db 'pause.bat',0
filename_quit   db 'quit.bat',0

message   db '@echo off',0Dh,0Ah
          db 'call host_play.bat MUSIC\SONG0X.MP3',0Dh,0Ah
msglen    equ $ - message

msg_pause db '@echo off',0Dh,0Ah
          db 'call host_play.bat pause',0Dh,0Ah
pause_msglen equ $ - msg_pause

msg_quit  db '@echo off',0Dh,0Ah
          db 'call host_play.bat quit',0Dh,0Ah
quit_msglen equ $ - msg_quit

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

    mov dx, offset install
    add dx, 15
    mov cl, 4
    shr dx, cl
    inc dx
    mov ax, 3100h
    int 21h

msg_installed db 'TSR installed: Press = then 1-7 play, =9 pause/resume, =0 quit, == (double =) uninstall TSR',0Dh,0Ah,'$'

end start