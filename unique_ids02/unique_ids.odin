package unique_ids

import "core:os"
import "core:math/rand"
import "core:strings"
import "core:encoding/json"

import "ulid"
import "../general"

run_test :: proc() {
	general.run(process_request)
}

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
		case "generate": {
			msg: Message(Generate_Request)
			json.unmarshal_string(json_string, &msg)

			/* 3.
			sb: strings.Builder
			defer strings.builder_destroy(&sb)
			*/
			resp := Message(Generate_Response){
				src  = msg.dest,
				dest = msg.src,

				body = {
					type = "generate_ok",
					id = generated_uuid(), // 1.
					// id = generate_id(), // 2.
					// id = generate_id_source_based(&sb, msg.dest, msg.body.msg_id), // 3.
					in_reply_to = msg.body.msg_id,
					msg_id = global_msg_id,
				},
			}
			global_msg_id += 1
			data, marshal_err := json.marshal(resp)
			return string(data), true
		}
		case: {}
		return "", false
	}
}

generated_uuid :: proc() -> u128 {
	id := rand.uint128()
	return id
}

generate_id :: proc() -> ulid.Ulid {
	id, _ := ulid.generate_monotonic_ulid()
	return id
}

generate_id_source_based :: proc(sb: ^strings.Builder, src: string, msg_id: int) -> string {
	strings.write_string(sb, src)
	strings.write_byte(sb, '-')
	strings.write_int(sb, msg_id)
	return strings.to_string(sb^)
}

Generate_Request :: struct {
	type  : string,
	echo  : string,
	msg_id: int,
}

Generate_Response :: struct {
	type: string,
	id: u128, // 1.
	// id: ulid.Ulid, // 2.
	// id: string, // 3.
	in_reply_to: int,
	msg_id: int,
}
