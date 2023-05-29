package general

import "core:os"
import "core:fmt"
import "core:encoding/json"

LINE_SIZE :: 1024
global_msg_id: int = 0

run :: proc(
	process_request: proc(json_string: string) -> (string, bool)
) {
	for true {
		buf: [LINE_SIZE]byte
		json_string, ok := read_line(buf[:])
		if !ok do continue
		response, found := process_request(json_string)
		if !found do continue
		fmt.println(response) // Write to stdout
	}
}

Generic_Request :: struct {
	type: string,
}

Init_Request :: struct {
	type    : string,
	msg_id  : int,
	node_id : string,
	node_ids: []string,
}

Init_Response :: struct {
	type       : string,
	in_reply_to: int,
}

Message :: struct($Body: typeid) {
	src : string, // Source      node of the message
	dest: string, // Destination node of the message
	body: Body,   // The payload of the message
}

read_line :: proc(buf: []byte) -> (string, bool) {
	n, err := os.read(os.stdin, buf)
	if err != 0 {
		panic("Deu ruim no read_line doidao")
	}
	if n == 0 {
		return "", false
	}
	return string(buf[:n]), true
}
