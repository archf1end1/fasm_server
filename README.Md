# Simple Web Server in FASM

This is a basic web server implemented in FASM (Flat Assembler) for x86-64 architecture. It listens for incoming HTTP connections on a specified port, and sends a simple HTML response.

## Features

* **Basic HTTP Handling:** Handles incoming HTTP requests and sends a "200 OK" response with a simple HTML page.
* **Socket Programming:** Uses the Linux system call interface for socket creation, binding, listening, and accepting connections.
* **Multi-Connection Handling:** The server can handle multiple client connections sequentially.
* **Error Handling:** Includes basic error handling for socket operations.
* **Assembly Implementation:** Written in FASM for performance and low-level control.

## Prerequisites

* **FASM (Flat Assembler):** You need to have FASM installed on your system to assemble the code.  Download it from http://flatassembler.net/
* **Linux System:** This code is written for Linux and uses Linux system calls.
* **Network Utilities:** Tools like `netcat`, `curl`, or a web browser to test the server.

## Getting Started

1.  **Save the code:** Save the provided FASM code into a file named `server.asm`.

2.  **Assemble the code:** Use FASM to assemble the `server.asm` file:
    ```bash
    fasm server.asm server
    ```
    This will create an executable file named `server`.

3.  **Run the server:**
    ```bash
    ./server
    ```
    The server will start listening for connections.  By default, it listens on port 8080 (34835 in decimal representation of reversed hex).

4.  **Test the server:**
    * **Using netcat:**
        ```bash
        nc localhost 8080
        ```
        Then, type:
        ```
        GET / HTTP/1.1
        Host: localhost
        
        ```
        (Make sure to press Enter twice after the `Host` line).  You should see the HTML response from the server.

    * **Using curl:**
        ```bash
        curl localhost:8080
        ```

    * **Using a web browser:**
        Open your web browser and go to `http://localhost:8080`.

## Code Explanation

The assembly code performs the following steps:

1.  **Initialization:**
    * Prints a starting message.
    * Defines constants for system calls, socket options, and other values.
    * Declares variables in the `readable writeable` segment for the socket file descriptor, connection file descriptor, and socket address structures.
    * Defines the HTTP response message.

2.  **Socket Creation:**
    * Calls the `socket` system call to create a socket.
    * Checks for errors.

3.  **Binding:**
    * Sets up the server address structure (`serveraddr`) with the address family (AF\_INET), port number (8080), and IP address (INADDR\_ANY).  The port number 8080 (0x1F90) is converted to network byte order (0xF901).
    * Calls the `bind` system call to bind the socket to the specified address and port.
    * Checks for errors.

4.  **Listening:**
    * Calls the `listen` system call to listen for incoming connections on the socket.
    * Checks for errors.

5.  **Accepting Connections (Loop):**
    * Enters a loop to accept incoming connections using the `accept` system call.
    * For each accepted connection:
        * Stores the client address information.
        * Sends the HTTP response message to the client using the `write` system call.
        * Closes the connection using the `close` system call.
        * Goes back to `next_request` to accept another connection.

6.  **Error Handling:**
    * If any of the socket operations (socket, bind, listen, accept) fail, the code jumps to the `error` label.
    * The `error` section prints an error message to standard error, closes the sockets (if they were successfully created), and exits with an error code (1).

7.  **Exit:**
    * After the connection loop (which in this code runs forever), the code prints a success message.
    * The  `close` system call closes the server socket.
    * The `exit` system call terminates the program with a success code (0).

##  Important Notes

* **Port Number:** The server listens on port 8080.  You can change this by modifying the `mov word [serveraddr.sin_port], 34835` line.  Remember to convert the port number to its hexadecimal representation, reverse the byte order, and then convert that reversed hex value back to decimal.
* **Error Handling:** The error handling is basic.  A production server would need more robust error checking and logging.
* **Security:** This is a very basic server and is **not secure** for production use.  It does not handle HTTP request parsing, security vulnerabilities, or other essential web server features.
* **Single-Threaded:** This server handles connections sequentially.  It can only handle one connection at a time.  For a more robust server, you would need to use multi-threading or asynchronous I/O.
* **HTTP Response:** The HTTP response is very simple and hardcoded.  A real web server would generate responses dynamically based on the requested resource.
* **Assembly:** Writing a web server in assembly provides fine-grained control and can be very efficient, but it's also more complex than using higher-level languages.
