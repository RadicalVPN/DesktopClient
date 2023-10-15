package service

import (
	"radicalvpnd/webapi"
	"time"

	probing "github.com/prometheus-community/pro-bing"
)

func PingServers(server []webapi.Server) []webapi.Server {
	for i, s := range server {
		if s.Online {
			server[i] = pingServer(s)
		}
	}

	return server
}

func pingServer(s webapi.Server) webapi.Server {
	log.Debug("Pinging ", s.ExternaIp)

	pinger, err := probing.NewPinger(s.ExternaIp)

	if err != nil {
		log.Error("Failed to create pinger for", s.Hostname, err.Error())
		return s
	}

	pinger.SetPrivileged(true)
	pinger.Count = 1
	pinger.Timeout = time.Millisecond * 10
	pinger.Run()

	stats := pinger.Statistics()
	if stats.AvgRtt > 0 {
		ttl := int(stats.AvgRtt / time.Millisecond)

		log.Info("Ping", s.Hostname, ": ", ttl, "ms")

		s.Latency = ttl
	}

	return s
}