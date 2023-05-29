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

var topology map[string]interface{}

var sent map[string][]float64 = make(map[string][]float64)

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

		// Send broadcasted message to all other nodes
		if topology != nil {
			myNeighbors := topology[n.ID()]
			for _, v := range myNeighbors.([]interface{}) {
				respBody := map[string]any{
					"type":      "node_broadcast",
					"neighbors": myNeighbors,
					"message":   body["message"].(float64),
				}
				err := n.Send(v.(string), respBody)
				if err != nil {
					panic("Heeeelp:")
				}
			}
		} else {
			panic("Ta maluko")
		}

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
		for k := range topology {
			sent[k] = []float64{}
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

	// New Handler to handle node_broadcasts
	n.Handle("node_broadcast", func(msg maelstrom.Message) error {
		// Unmarshal the message body as an loosely-typed map.
		var body map[string]any
		if err := json.Unmarshal(msg.Body, &body); err != nil {
			return err
		}

		// Update globalMessages with only new received messages
		message := body["message"].(float64)
		for _, v := range globalMessages {
			if message == v { // Already have it
				return nil
			}
		}
		globalMessages = append(globalMessages, message)

		// Send to nodes that haven't been sent yet
		nodesReceived := body["neighbors"].([]interface{})
		myNeighbors := topology[n.ID()]
		var onlyMine []interface{}
		for _, k := range myNeighbors.([]interface{}) {
			if !contains(nodesReceived, k.(string)) {
				onlyMine = append(onlyMine, k.(string))
			}
		}
		allNodes := append(nodesReceived, onlyMine...)
		for _, v := range onlyMine {
			sent[v.(string)] = append(sent[v.(string)], message)
			gossipBody := map[string]any{
				"type":      "node_broadcast",
				"neighbors": allNodes,
				"message":   message,
			}
			err := n.Send(v.(string), gossipBody)
			if err != nil {
				panic("Complicado issae")
			}
		}

		/* time.Sleep(time.Second)
		for _, v := range sent {
			if len(v) != 0 {
				// Resend the messages
			}
		}
		*/

		// After 1 second, retry to send the message
		/*
			time.Sleep(time.Second)
			// Send to nodes that haven't been sent yet
			for _, v := range onlyMine {
				gossipBody := map[string]any{
					"type":      "node_broadcast",
					"neighbors": allNodes,
					"message":   message,
				}
				err := n.Send(v.(string), gossipBody)
				if err != nil {
					panic("Complicado issae")
				}
			}
		*/

		return nil
	})

	// Execute the node's message loop. This will run until STDIN is closed.
	if err := n.Run(); err != nil {
		log.Printf("ERROR: %s", err)
		os.Exit(1)
	}
}

func contains(list []interface{}, b string) bool {
	for _, v := range list {
		if v.(string) == b {
			return true
		}
	}
	return false
}
