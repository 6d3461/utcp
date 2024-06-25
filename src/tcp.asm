section .data

; The first and second bytes describe the ethernet flags and protocol respictively.
; The IP header is 20 length.
; This frame has 12 octets trailer.
tcp_syn_frame db 0h, 0h, 8h, 0h, 45h, 0h, 0h, 3ch, 7fh, 1ch, 40h, 0h, 40h, 6h, 3ah, 4ch, 0c0h, 0a8h, 0h, 1h, 0c0h, 0a8h, 0h, 2h, 92h, 62h, 0h, 50h, 46h, 3dh, 0d1h, 4eh, 0h, 0h, 0h, 0h, 0a0h, 2h, 0fah, 0f0h, 51h, 2fh, 0h, 0h, 2h, 4h, 5h, 0b4h, 4h, 2h, 8h, 0ah, 0d2h, 0fh, 0feh, 3dh, 0h, 0h, 0h, 0h, 1h, 3h, 3h, 7h

err_eth_proto_not_ipv4 db "ethernet protocol is not ipv4"
err_eth_proto_not_ipv4_len equ $-err_eth_proto_not_ipv4

section .text

extern printf

global main
main:
    mov rbp, rsp; for correct debugging
    
    call on_rcvd_frame
    
    xor rax, rax
    ret
    
on_rcvd_frame:
    lea rdi, tcp_syn_frame
    call eth_proto_must_ipv4
    
    call print_source_destination
    
    ; TODO
    ; Check the flags syn, ack, etc.
    
    ret

; The ethernet protocol must be IPv4 (0800)
; The first and second words describe the flags and protocol respectively.
; https://www.colasoft.com/help/7.1/appe_codes_ethernet.html
eth_proto_must_ipv4:
    cmp word [rdi + 2], 0008h
    jnz .eth_proto_not_ipv4
    ret
    
.eth_proto_not_ipv4:
    lea rcx, err_eth_proto_not_ipv4
    mov rdx, err_eth_proto_not_ipv4_len
    call print
    call exit


print_source_destination:
    xor rax, rax
    xor rsi, rsi
    xor rdx, rdx
    xor rcx, rcx
    xor r8, r8
    
    mov rdi, .pformat
    
    mov sil, byte [tcp_syn_frame + 19] ; Source IP
    mov dx, word [tcp_syn_frame + 24] ; Source Port
    xchg dl, dh
    
    mov cl, byte [tcp_syn_frame + 23] ; Destination IP
    ; r8w does not have lower part.
    mov ax, word [tcp_syn_frame + 26] ; Destination Port
    xchg al, ah
    mov r8w, ax
    
    mov al, 0
    call printf
    ret
    
.pformat:
	db `x.x.x.%d:%d -> x.x.x.%d:%d\n`, 0

print:
    mov rbx, 1
    mov rax, 4
    int 0x80
    ret
    
exit:
    mov rax, 1
    int 0x80