#include <stdio.h>

char msg_overflow[] = "error!overflow$";

void into_service() {
    __asm__ __volatile__ (
        "push ax\n"   
        "push dx\n"   
        "mov ah, 09h\n"  
        "lea dx, %1\n"   
        "int 21h\n"      
        "pop dx\n"    
        "pop ax\n"   
        "iret\n"      
        :
        : "m" (msg_overflow)  
}


void set_interrupt_vector() {
    __asm__ __volatile__ (
        "cli\n"       
        "mov ax, 0\n"
        "mov es, ax\n" 
        "mov word ptr es:[16], %0\n"    
        "mov word ptr es:[18], cs\n"   
        "sti\n"       
        :
        : "r" (into_service)  
    );
}

int main() {
    short a = 32767;  
    short b = 1;      
    short sum;

    
    set_interrupt_vector();

   
    __asm__ __volatile__ (
        "mov ax, %1\n"  
        "mov bx, %2\n"  
        "add ax, bx\n"
        "into\n"        
        "mov %0, ax\n"  
        : "=r" (sum)      
        : "r" (a), "r" (b) 
    );

    return 0;
}