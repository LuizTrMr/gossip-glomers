package unique_ids

import "core:os"
import "core:fmt"
import "core:math/rand"
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
		case "generate": {
			msg: Message(Generate_Request)
			json.unmarshal_string(json_string, &msg)
			// write(logger, something)

			resp := Message(Generate_Response){
				src  = msg.dest,
				dest = msg.src,
				body = {
					type = "generate_ok",
					id = generated_uuid(),
					in_reply_to = msg.body.msg_id,
					msg_id = global_msg_id,
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


Generate_Request :: struct {
	type  : string,
	echo  : string,
	msg_id: int,
}

Generate_Response :: struct {
	type: string,
	id: u128,
	in_reply_to: int,
	msg_id: int,
}

generated_uuid :: proc() -> u128 {
	id := rand.uint128()
	return id
}
