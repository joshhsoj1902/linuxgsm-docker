package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

func main() {
	httpServer := newHttpTransport()
	http.HandleFunc("/", helloServer)
	http.HandleFunc("/live", httpServer.liveServer)
	http.HandleFunc("/ready", httpServer.readyServer)
	fmt.Printf("Listening on port 28080\n")
	http.ListenAndServe(":28080", nil)
}

func helloServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}

func newHttpTransport() *httpTransport {
	gamedig := newGamedig()

	return &httpTransport{
		gamedig: gamedig,
	}
}

// Gamedig service
type httpTransport struct {
	gamedig *gamedig
}

func (h httpTransport) liveServer(w http.ResponseWriter, r *http.Request) {

	// result, err := h.gamedig.query()

	// if err != nil || result["error"] != "" {
	// 	w.WriteHeader(http.StatusServiceUnavailable)
	// 	return
	// }

	w.WriteHeader(http.StatusOK)
}

func (h httpTransport) readyServer(w http.ResponseWriter, r *http.Request) {

	_, err := os.Stat("INSTALLING.LOCK")
	// If the file exists, it's not ready
	if !os.IsNotExist(err) {
		w.WriteHeader(http.StatusServiceUnavailable)
		fmt.Fprintf(w, "Game installing\n")
		return
	}

	result, err := h.gamedig.query()

	if err != nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		fmt.Fprintf(w, "Error querying\n")
		return
	}

	if result["error"] != nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		fmt.Fprintf(w, "Query returned error\n")
		return
	}

	w.WriteHeader(http.StatusOK)
	// fmt.Fprintf(w, "Ready, %+v!", result)
	fmt.Fprintf(w, "Ready")
}

// Gamedig service
type gamedig struct {
	serverIP   string
	gameType   string
	serverPort string
}

func newGamedig() *gamedig {
	serverIP := os.Getenv("LGSM_MONITOR_IP")
	if serverIP == "" {
		serverIP = getHostname()
	}

	gamedigType := getGamedigType(os.Getenv("LGSM_GAMESERVERNAME"))
	serverPort := os.Getenv("LGSM_PORT")

	return &gamedig{
		serverIP:   serverIP,
		serverPort: serverPort,
		gameType:   gamedigType,
	}
}

func (g *gamedig) query() (map[string]interface{}, error) {
	app := "gamedig"

	arg0 := "--type"
	arg1 := g.gameType
	arg2 := fmt.Sprintf("%s:%s", g.serverIP, g.serverPort)

	cmd := exec.Command(app, arg0, arg1, arg2)
	stdout, err := cmd.Output()

	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}

	// Declared an empty interface
	var result map[string]interface{}

	// Unmarshal or Decode the JSON to the interface.
	json.Unmarshal(stdout, &result)

	// fmt.Printf("The results %+v\n", result)

	return result, nil
}

// This should only happen once
func getHostname() string {
	app := "hostname"
	arg0 := "-i"

	cmd := exec.Command(app, arg0)
	stdout, err := cmd.Output()

	if err != nil {
		fmt.Println(err.Error())
		return ""
	}
	return strings.Trim(string(stdout), "\n")
}

// If the LGSM code doesn't match the gamedig code, map it here
func getGamedigType(code string) string {
	shortCode := strings.Replace(code, "server", "", -1)

	// TODO: combare the lists and add any exceiptions that are missing:
	// https://github.com/GameServerManagers/LinuxGSM/blob/master/lgsm/data/serverlist.csv
	// https://github.com/gamedig/node-gamedig#supported

	switch shortCode {
	case "foo":
		return "foo"
	default:
		return shortCode
	}
}
