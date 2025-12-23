.model small
.stack 100h

.data
    sum dw 0       
    msg db 'sum 1 to 100 = $'  

.code
start:
    mov ax, @data
    mov ds, ax      

    mov cx, 1       
    mov ax, 0       

loop1:
    add ax, cx      
    inc cx          
    cmp cx, 101     
    jl loop1        

    mov sum, ax     ; 将累加结果存入数据段变量 `sum`（结果保存在数据段）

    
    mov ah, 09h
    lea dx, msg
    int 21h

    
    mov ax, sum
    call print_num

    
    mov ah, 4ch
    int 21h


print_num proc
    push ax
    push bx
    push cx
    push dx

    mov cx, 0       
    mov bx, 10      

divide:
    mov dx, 0       
    div bx          
    push dx         
    inc cx          
    cmp ax, 0       
    jne divide

    
print_loop:
    pop dx
    add dl, 30h     
    mov ah, 02h     
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

end start