format	ELF64 executable

SYS_write equ 1
SYS_exit equ 60
SYS_socket equ 41
SYS_bind equ 49
SYS_listen equ 50
SYS_close equ 3
SYS_accept equ 43

AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY equ 0
MAX_CONN equ 5


STDOUT equ 1
STDERR equ 2

macro write fd, buf, count
{
	mov rax, SYS_write
	mov rdi, fd
	mov rsi, buf
	mov rdx, count
	syscall
}

macro exit code
{
	mov rax, SYS_exit
	mov rdi, code
	syscall
}

macro socket domain, type, protocol
{
	mov rax, SYS_socket
	mov rdi, domain
	mov rsi, type
	mov rdx, protocol
	syscall
}

macro bind sockfd, addr, addrlen
{
	mov rax, SYS_bind
	mov rdi, sockfd
	mov rsi, addr
	mov rdx, addrlen
	syscall
}

macro listen sockfd, backlog
{
	mov rax, SYS_listen
	mov rdi, sockfd
	mov rsi, backlog
	syscall
}

macro accept sockfd, addr, addrlen
{
	mov rax, SYS_accept
	mov rdi, sockfd
	mov rsi, addr
	mov rdx, addrlen
	syscall
}

macro close fd
{
	mov rax, SYS_close
	mov rdi, fd
}

segment readable executable
entry main
main:
	write 1, start, start_size

	write STDOUT, socket_info_msg, socket_info_msg_len
	socket AF_INET, SOCK_STREAM, 0
	;socket 69, 320, 0
	cmp rax, 0
	jl error
	mov qword [sockfd], rax

	write STDOUT, bind_info_msg, bind_info_msg_len
	mov word [serveraddr.sin_family], AF_INET
	mov word [serveraddr.sin_port], 34835
	mov dword [serveraddr.sin_addr], INADDR_ANY
	bind [sockfd], serveraddr.sin_family, sizeof_servaddr
	cmp rax, 0
	jl error

	write STDOUT, listen_info_msg, listen_info_msg_len
	listen [sockfd], MAX_CONN
	cmp rax, 0
	jl error

next_request:
	write STDOUT, accept_info_msg, accept_info_msg_len
	accept [sockfd], clientaddr.sin_family, clientaddr_len
	cmp rax, 0
	jl error

	mov qword [connfd], rax

	write [connfd], response, response_len

	jmp next_request

	write STDOUT, success_msg, success_msg_len
	close [sockfd]
	exit 0
 
error:
	write STDERR, error_msg, error_msg_len
	close [connfd]
	close [sockfd]
	exit 1

segment readable writeable

sockfd dq -1
connfd dq -1

struc servaddr_in
{
	.sin_family dw 0
	.sin_port dw 0
	.sin_addr dd 0
	.sin_zero dq 0
	;.size = .sin_family - $
}

serveraddr servaddr_in
clientaddr servaddr_in
sizeof_servaddr = $ - serveraddr.sin_family
clientaddr_len dd sizeof_servaddr

hello db "Hello World! this is server", 10
hello_len = $ - hello

response db "HTTP/1.1 200 OK", 13, 10
	 db "Content-Type: text/html; charset=utf-8", 13, 10
	 db "Connection: close", 13, 10
	 db  13, 10
	 db "<h1>HELLO THIS IS WEB SERVER</h1>", 10
response_len = $ - response

start db "INFO: Starting the Web Server.....", 10
start_size = $ - start
socket_info_msg db "INFO: Creating a Socket.....", 10
socket_info_msg_len = $ - socket_info_msg
bind_info_msg db "INFO: Binding the socket.....", 10
bind_info_msg_len = $ - bind_info_msg
listen_info_msg db "INFO: Listning to socket.....", 10
listen_info_msg_len = $ - listen_info_msg
accept_info_msg db "INFO: Waiting for client to connect.....", 10
accept_info_msg_len = $ - accept_info_msg
success_msg db "SUCCESS: OK!", 10
success_msg_len = $ - success_msg
error_msg db "ERROR: Error has been occured!", 10
error_msg_len = $ - error_msg
