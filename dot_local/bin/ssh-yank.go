/*
 * This program listens on a local TCP port and copies the received data to the clipboard.
 *
 * Port number can be set with $PORT. Default is 54321.
 *
 * Log into the remote machine with remote port forwarding:
 *   ssh -R 12345:localhost:54321 user@remote
 * And copy data using:
 *   echo "Hello, world" | nc -w 1 localhost 12345
 */

package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"
	"syscall"
)

func handleConnection(conn net.Conn) {
	r, w := io.Pipe()

	cmd := exec.Command("pbcopy")
	cmd.Stdin = r
	cmd.Stdout = io.Discard
	cmd.Stderr = io.Discard

	err := cmd.Start()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error starting pbcopy:", err)
		conn.Close()
		return
	}

	go func() {
		defer conn.Close()
		defer w.Close()
		_, err := io.Copy(w, conn)
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error copying data:", err)
		}
	}()

	err = cmd.Wait()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error running pbcopy:", err)
	}
}

func runListener(port string) {
	listener, err := net.Listen("tcp", "127.0.0.1:"+port)
	if err != nil {
		log.Fatalf("Error creating listener: %v", err)
	}
	defer listener.Close()
	log.Println("Listening on port " + port)

	for {
		if !isSSHRunning() {
			os.Exit(0)
		}
		conn, err := listener.Accept()
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error accepting connection:", err)
			continue
		}
		go handleConnection(conn)
	}
}

func isSSHRunning() bool {
	cmd := exec.Command("pgrep", "-x", "ssh")
	err := cmd.Run()
	return err == nil
}

func heartbeat() {
	cmd := exec.Command("/bin/zsh", "-c", "while (pgrep -qx ssh) && (pgrep -qx ssh-yank); do sleep 10; done; pkill ssh-yank")
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setpgid: true,
	}
	_ = cmd.Start()
}

func main() {
	if !isSSHRunning() {
		fmt.Fprintln(os.Stderr, "SSH is not running")
		return
	}
	if os.Getenv("RUN_LISTENER") == "1" {
		port := os.Getenv("PORT")
		if port == "" {
			port = "54321"
		}
		runListener(port)
	} else {
		cmd := exec.Command(os.Args[0])
		cmd.Env = append(os.Environ(), "RUN_LISTENER=1")
		cmd.Stdout = nil
		cmd.Stderr = nil
		err := cmd.Start()
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error starting background process:", err)
			return
		}
		heartbeat()
	}
}
