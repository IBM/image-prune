package main

import (
	"github.com/IBM/image-prune/cmd"

	"github.com/containers/storage/pkg/reexec"
	"github.com/sirupsen/logrus"
)

func main() {
	if reexec.Init() {
		return
	}
	rootCmd, _ := cmd.CreateApp()
	if err := rootCmd.Execute(); err != nil {
		if cmd.IsNotFoundImageError(err) {
			logrus.StandardLogger().Log(logrus.FatalLevel, err)
			logrus.Exit(2)
		}
		logrus.Fatal(err)
	}
}
