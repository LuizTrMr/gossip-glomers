package general

import "core:os"
import "core:fmt"
import "core:encoding/json"

LINE_SIZE :: 1024
global_msg_id: int = 0

run :: proc(process_request: proc(json_string: string, logger: os.Handle) -> (string, bool)) {
	logger, err := os.open("log.txt", os.O_CREATE | os.O_WRONLY,  0o644)
	if err != 0 {
		panic("Deu bosta")
	}
	write(logger, "LOG START\n")
	for true {
		buf: [LINE_SIZE]byte
		json_string, ok := read_line(buf[:])
		if !ok do continue
		response, found := process_request(json_string, logger)
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
	src : string, // A string identifying the node this message came from
	dest: string, // A string identifying the node this message is to
	body: Body,   // An object: the payload of the message
}

write :: proc(h: os.Handle, s: string) {
	// TODO: Sla que eu tinha feito aqui antes de fazer merda com o git
	os.write(h, transmute([]byte)s)
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
