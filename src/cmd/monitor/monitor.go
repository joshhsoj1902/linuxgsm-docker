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
	http.HandleFunc("/live", httpServer.liveServer)
	http.HandleFunc("/ready", httpServer.readyServer)
	http.HandleFunc("/gamedig", httpServer.gamedigServer)

	// 28080 is my attempt to not collide with any gameserver ports
	fmt.Printf("Listening on port 28080\n")
	http.ListenAndServe(":28080", nil)
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

	if h.gamedig.gameType != "" {
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
	} else {
		// If game doesn't support gamedig, fallback on monitor
		result, reason := lgsmMonitor()
		if result == false {
			w.WriteHeader(http.StatusServiceUnavailable)
			fmt.Fprintf(w, "%s\n", reason)
			return
		} else {
			w.WriteHeader(http.StatusOK)
			fmt.Fprintf(w, "%s\n", reason)
			return
		}
	}
}

func (h httpTransport) gamedigServer(w http.ResponseWriter, r *http.Request) {

	if h.gamedig.gameType != "" {
		result, _ := h.gamedig.query()

		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "%+v!", result)
	} else {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "Gameserver doesn't support gamedig.")
	}

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

	serverPort := os.Getenv("LGSM_QUERY_PORT")
	if serverPort == "" {
		serverPort = os.Getenv("LGSM_PORT")
	}

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

	var result map[string]interface{}
	json.Unmarshal(stdout, &result)

	// fmt.Printf("The results %+v\n", result)
	return result, nil
}

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
	case "ac":
		return "assettocorsa"
	case "ahl":
		return ""
	case "ahl2":
		return ""
	case "ark":
		return "arkse"
	case "arma3":
		return "arma3"
	case "av":
		return ""
	case "bb":
		return ""
	case "bb2":
		return ""
	case "bd":
		return ""
	case "bf1942":
		return "bf1942"
	case "bfv":
		return "bfv"
	case "bmdm":
		return ""
	case "bo":
		return ""
	case "bs":
		return ""
	case "bt":
		return ""
	case "bt1944":
		return "bat1944"
	case "cc":
		return ""
	case "cmw":
		return ""
	case "cod":
		return "cod"
	case "cod2":
		return "cod2"
	case "cod4":
		return "cod4"
	case "codou":
		return "coduo"
	case "codwaw":
		return "codwaw"
	case "cs":
		return "cs16"
	case "cscz":
		return "cscz"
	case "csgo":
		return "csgo"
	case "css":
		return "css"
	case "dab":
		return ""
	case "dmc":
		return ""
	case "dod":
		return "dod"
	case "dods":
		return "dods"
	case "doi":
		return "doi"
	case "dst":
		return ""
	case "eco":
		return ""
	case "em":
		return ""
	case "etl":
		return ""
	case "fctr":
		return ""
	case "fof":
		return ""
	case "ges":
		return "ges"
	case "gmod":
		return "garrysmod"
	case "hl2dm":
		return "hl2dm"
	case "hldm":
		return "hldm"
	case "hldms":
		return "hldms"
	case "hw":
		return "hurtworld"
	case "ins":
		return "insurgency"
	case "inss":
		return "insurgencysandstorm"
	case "ios":
		return ""
	case "jc2":
		return "jc2mp"
	case "jc3":
		return "jc3mp"
	case "kf":
		return "killingfloor"
	case "kf2":
		return "killingfloor2"
	case "l4d":
		return "left4dead"
	case "l4d2":
		return "left4dead2"
	case "mc":
		return "minecraft"
	case "mcb":
		return "minecraftbe"
	case "mh":
		return "mordhau"
	case "mohaa":
		return "mohaa"
	case "mom":
		return ""
	case "mta":
		return "mtasa"
	case "mumble":
		return "mumble"
	case "nd":
		return "nucleardawn"
	case "nmrih":
		return "nmrih"
	case "ns":
		return "ns"
	case "ns2":
		return "ns2"
	case "ns2c":
		return ""
	case "onset":
		return "onset"
	case "opfor":
		return ""
	case "pc":
		return ""
	case "pstbs":
		return ""
	case "pvkii":
		return ""
	case "pz":
		return ""
	case "q2":
		return "quake2"
	case "q3":
		return "quake3"
	case "ql":
		return "quakelive"
	case "qw":
		return "quake1"
	case "ricochet":
		return "ricochet"
	case "ro":
		return "redorchestraost"
	case "rtcw":
		return "rtcw"
	case "rust":
		return "rust"
	case "rw":
		return ""
	case "samp":
		return "samp"
	case "sb":
		return "starbound"
	case "sbots":
		return ""
	case "sdtd":
		return "7d2d"
	case "sfc":
		return ""
	case "sof2":
		return "sof2"
	case "sol":
		return "soldat"
	case "squad":
		return "squad"
	case "ss3":
		return ""
	case "st":
		return ""
	case "sven":
		return "svencoop"
	case "terraria":
		return "terraria"
		// return "tshock"
	case "tf2":
		return "tf2"
	case "tfc":
		return "tfc"
	case "ts":
		return ""
	case "ts3":
		return "teamspeak3"
	case "tu":
		return "towerunite"
	case "tw":
		return ""
	case "unt":
		return "unturned"
	case "ut":
		return "ut"
	case "ut2k4":
		return "ut2004"
	case "ut3":
		return "ut3"
	case "ut99":
		return ""
	case "vs":
		return ""
	case "wet":
		return "wolfensteinet"
	case "wf":
		return ""
	case "wurm":
		return ""
	case "zmr":
		return "zombiemaster"
	case "zps":
		return "zps"
	default:
		fmt.Printf("Unexpected GameServer type (%s)\n", code)
		return ""
	}
}

func lgsmMonitor() (bool, string) {
	app := "./lgsm-gameserver"
	arg0 := "monitor"

	cmd := exec.Command(app, arg0)
	stdout, err := cmd.Output()

	if err != nil {
		return false, "Error querying"
	}

	if strings.Contains(string(stdout), "DELAY") {
		return false, "Starting"
	}

	if cmd.ProcessState.ExitCode() > 0 {
		return false, "Query returned error"
	}

	return true, "Ready"
}
