package main

import (
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/spf13/pflag"
	"go.uber.org/zap"

	"github.com/sachinms27/go-api/docs"
	"github.com/sachinms27/go-api/pkg/api"
	"github.com/sachinms27/go-api/pkg/db"
)

var (
	version string
	addr    string
)

func init() {
	pflag.StringVarP(&addr, "address", "a", ":8080", "the address for the api to listen on. Host and port separated by ':'")
	pflag.Parse()
}

func main() {
	version = "1.0"
	docs.SwaggerInfo.Version = version

	// gracefully exit on keyboard interrupt
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	// configure logger
	log, _ := zap.NewDevelopment(zap.WithCaller(true))
	defer func() {
		_ = log.Sync()
	}()

	// print current version
	log.Info("starting up API...", zap.String("version", version))

	dbClient := &db.Client{}
	if err := dbClient.Connect(os.Getenv("DB_CONNECTION")); err != nil {
		log.Error("couldn't connect to database", zap.Error(err))
		os.Exit(1)
	}

	// start the api server
	r := api.GetRouter(log, dbClient)
	go func() {
		if err := http.ListenAndServe(addr, r); err != nil {
			log.Error("failed to start server", zap.Error(err))
			os.Exit(1)
		}
	}()

	log.Info("ready to serve requests on " + addr)
	<-c
	log.Info("gracefully shutting down")
	os.Exit(0)
}
