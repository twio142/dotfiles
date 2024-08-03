/* Open a TCP listener on a port and copy the received data to the clipboard.
   Requires `ssh -R` to forward a port from the remote machine to the local machine.
   Default port is 54321, but can be overridden by setting the `PORT` env var. */

package main

import (
	"bufio"
	"fmt"
	"io"
	"net"
	"os"
	"os/exec"
	"strings"
	"time"
)

func writeToClipboard(data string) error {
	cmd := exec.Command("pbcopy")
	cmd.Stdin = strings.NewReader(data)
	return cmd.Run()
}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	reader := bufio.NewReader(conn)
	var buffer strings.Builder

	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				buffer.WriteString(line)
				break
			}
			fmt.Fprintln(os.Stderr, "Error reading from connection:", err)
			return
		}
		buffer.WriteString(line)
	}

	data := buffer.String()
	fmt.Println(data)
	if err := writeToClipboard(data); err != nil {
		fmt.Fprintln(os.Stderr, "Error writing to clipboard:", err)
	}
}

func runListener() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "54321"
	}
	address := "127.0.0.1:" + port
	listener, err := net.Listen("tcp", address)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error starting TCP listener:", err)
		return
	}
	defer listener.Close()

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
		time.Sleep(30 * time.Second)
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
