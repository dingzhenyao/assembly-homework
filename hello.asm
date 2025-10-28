.model small  
.stack 100h   

.data         
    msg db 'helloworld', 0dh, 0ah, '$'  
    

.code         
start:        
    
    mov ax, @data  
    mov ds, ax     

    mov ah, 09h    ; 设置DOS中断功能号：09h = 输出字符串
    lea dx, msg    
    int 21h        ; 执行DOS中断：输出DX指向的字符串（直到遇到'$'结束）

    mov ah, 4ch    ; 设置DOS中断功能号：4ch = 程序退出
    int 21h        ; 执行中断：结束程序，返回DOS

end start     
