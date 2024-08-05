/*
 * This program listens on a TCP port and copies the data it receives to the clipboard.
 *
 * If the remote machine can access your local port directly, you can use this to copy
 *   echo "Hello, world" | nc -w 1 $(echo $SSH_CLIENT | cut -d' ' -f1) 54321
 *
 * Otherwise, use SSH port forwarding to log in to the remote machine:
 *   ssh -R 54321:localhost:54321 user@remote
 * And copy data using:
 *   echo "Hello, world" | nc -w 1 localhost 54321
 */

package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"
	"time"
)

func handleConnection(conn net.Conn) {
	// Create a pipe for connecting to pbcopy
	r, w := io.Pipe()

	// Start pbcopy command
	cmd := exec.Command("pbcopy")
	cmd.Stdin = r
	cmd.Stdout = io.Discard // Discard stdout as we don't need it
	cmd.Stderr = io.Discard // Discard stderr

	// Start the pbcopy command
	err := cmd.Start()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error starting pbcopy:", err)
		conn.Close()
		return
	}

	// Copy data from the connection to the pipe
	go func() {
		defer conn.Close()
		defer w.Close()
		_, err := io.Copy(w, conn)
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error copying data:", err)
		}
	}()

	// Wait for pbcopy to finish
	err = cmd.Wait()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error running pbcopy:", err)
	}
}

func runListener() {
	// Listen on TCP port 54321
	listener, err := net.Listen("tcp", ":54321")
	if err != nil {
		log.Fatalf("Error creating listener: %v", err)
	}
	defer listener.Close()
	log.Println("Listening on port 54321")

	for {
		if !isSSHRunning() {
			os.Exit(0)
		}
		// Accept new connections
		conn, err := listener.Accept()
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error accepting connection:", err)
			continue
		}

		// Handle each connection concurrently
		go handleConnection(conn)
		time.Sleep(10 * time.Second)
	}
}

func isSSHRunning() bool {
	cmd := exec.Command("pgrep", "-x", "ssh")
	err := cmd.Run()
	return err == nil
}

func main() {
	if !isSSHRunning() {
		fmt.Fprintln(os.Stderr, "SSH is not running")
		return
	}
	if os.Getenv("RUN_LISTENER") == "1" {
		runListener()
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
	}
}
