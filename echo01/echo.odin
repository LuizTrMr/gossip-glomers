package echo01

import "core:os"
import "core:fmt"
import "core:encoding/json"
import "../general"

run_test :: proc() {
	general.run(process_request)
}

process_request :: proc(json_string: string, logger: os.Handle) -> (string, bool) { using general
	check_msg: Message(Generic_Request)
	json.unmarshal_string(json_string, &check_msg)
	
	switch check_msg.body.type {
		case "init": {
			msg: Message(Init_Request)
			json.unmarshal_string(json_string, &msg)
			// write(logger, something)

			resp := Message(Init_Response){
				src  = msg.dest,
				dest = msg.src,
				body = {
					type = "init_ok",
					in_reply_to = msg.body.msg_id,
				},
			}
			data, marshal_err := json.marshal(resp)
			// write(logger, something)
			return string(data), true
		}
		case "echo": {
			msg: Message(Echo_Request)
			json.unmarshal_string(json_string, &msg)
			// write(logger, something)

			resp := Message(Echo_Response){
				src  = msg.dest,
				dest = msg.src,
				body = {
					type = "echo_ok",
					echo = msg.body.echo,
					msg_id = global_msg_id,
					in_reply_to = msg.body.msg_id,
				},
			}
			global_msg_id += 1
			data, marshal_err := json.marshal(resp)
			// write(logger, something)
			return string(data), true
		}
		case: {}
		return "", false
	}
}

Echo_Request :: struct {
	type  : string,
	echo  : string,
	msg_id: int,
}

Echo_Response :: struct {
	type: string,
	echo: string,
	msg_id: int,
	in_reply_to: int,
}
