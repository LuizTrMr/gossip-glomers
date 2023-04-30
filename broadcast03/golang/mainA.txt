package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	maelstrom "github.com/jepsen-io/maelstrom/demo/go"
)

var globalMessages []float64 = []float64{}
var globalMessageID int = 0

// var topology map[string][]string
var topology map[string]interface{}

func main() {
	n := maelstrom.NewNode()

	n.Handle("broadcast", func(msg maelstrom.Message) error {
		// Unmarshal the message body as an loosely-typed map.
		var body map[string]any
		if err := json.Unmarshal(msg.Body, &body); err != nil {
			return err
		}

		// Update the message type.
		resp := map[string]any{
			"type": "broadcast_ok",
		}
		globalMessages = append(globalMessages, body["message"].(float64))

		// Echo the original message back with the updated message type.
		return n.Reply(msg, resp)
	})

	n.Handle("topology", func(msg maelstrom.Message) error {
		// Unmarshal the message body as an loosely-typed map.
		var body map[string]any
		if err := json.Unmarshal(msg.Body, &body); err != nil {
			return err
		}

		// Update the message type.
		var ok bool
		topology, ok = body["topology"].(map[string]interface{})
		if !ok {
			fmt.Printf("Body topology = %v; global topology = %v\n", body["topology"], topology)
		}
		resp := map[string]any{
			"type":        "topology_ok",
			"in_reply_to": body["msg_id"],
			"msg_id":      globalMessageID,
		}
		globalMessageID += 1

		// Echo the original message back with the updated message type.
		return n.Reply(msg, resp)
	})

	n.Handle("read", func(msg maelstrom.Message) error {
		// Unmarshal the message body as an loosely-typed map.
		var body map[string]any
		if err := json.Unmarshal(msg.Body, &body); err != nil {
			return err
		}

		// Update the message type.
		resp := map[string]any{
			"type":     "read_ok",
			"messages": globalMessages,
		}

		// Echo the original message back with the updated message type.
		return n.Reply(msg, resp)
	})

	// Execute the node's message loop. This will run until STDIN is closed.
	if err := n.Run(); err != nil {
		log.Printf("ERROR: %s", err)
		os.Exit(1)
	}
}
