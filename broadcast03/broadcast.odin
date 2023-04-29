package broadcast03

import "core:encoding/json"
import "core:os"
import "core:fmt"
import "../general"

run_test :: proc() {
	general.run(process_request)
}

broadcast_messages := [dynamic]int{}

process_request :: proc(json_string: string) -> (string, bool) { using general
	check_msg: Message(Generic_Request)
	json.unmarshal_string(json_string, &check_msg)
	switch check_msg.body.type {
		case "init": {
			msg: Message(Init_Request)
			json.unmarshal_string(json_string, &msg)

			resp := Message(Init_Response){
				src  = msg.dest,
				dest = msg.src,
				body = {
					type = "init_ok",
					in_reply_to = msg.body.msg_id,
				},
			}
			data, marshal_err := json.marshal(resp)
			return string(data), true
		}
		case: {}
	}
	return "", false
}

Broadcast_Request :: struct {
	type   : string,
	message: int,
}

Broadcast_Response :: struct {
	type: string,
}

Read_Request :: struct {
	type: string,
}

Read_Response :: struct {
	type    : string,
	messages: []int,
}

Topology_Request :: struct {
	type   : string,
	topology: map[string][]string,
	// "topology": {
		// "n1": ["n2", "n3"],
		// "n2": ["n1"],
		// "n3": ["n1"]
	// }
}

Topology_Response :: struct {
	type: string,
}

