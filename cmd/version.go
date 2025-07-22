package cmd

import (
	// Standard library modules
	"fmt"

	// Open source dependency modules
	"github.com/spf13/cobra"
)

// Public variables for image-prune version
var ImagePruneVersion string = "v1.0.0-local.build"
var ImagePruneBuildDate string = "N/a"
var ImagePruneCommit string = "N/a"

// The image-prune version command prints the version of the image-prune CLI
func versionCmd() *cobra.Command {
	// Initialize the cppm version command
	versionCommand := &cobra.Command{
		Use:   "version",
		Short: "Get the version of the image-prune CLI",
		Long:  "The version command prints the version of the image-prune CLI",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("Image prune CLI")
			fmt.Printf("Version:\t%s\n", ImagePruneVersion)
			fmt.Printf("Build date:\t%s\n", ImagePruneBuildDate)
			fmt.Printf("Commit hash:\t%s\n", ImagePruneCommit)
		},
	}

	// Return the fyre version command
	return versionCommand
}
