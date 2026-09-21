package main

import (
	"github.com/spf13/cobra"
	"harnessforge/internal/generation/application"
	"harnessforge/internal/generation/infrastructure"
	harnessinfra "harnessforge/internal/harness/infrastructure"
)

func newGenerateCommand() *cobra.Command {
	var file, repository, bendGenerator string
	command := &cobra.Command{Use: "generate [codex|claude]", Short: "Generate reviewed agent instructions", Args: cobra.ExactArgs(1), RunE: func(cmd *cobra.Command, args []string) error {
		var adapter application.Adapter = infrastructure.Markdown{Agent: args[0]}
		if bendGenerator != "" {
			adapter = infrastructure.BendMarkdown{Executable: bendGenerator, Agent: args[0]}
		}
		return application.NewGenerate(harnessinfra.YAMLLoader{}, adapter, infrastructure.FileWriter{}).Execute(cmd.Context(), file, repository)
	}}
	command.Flags().StringVar(&file, "file", ".harness/harness.yaml", "Harness YAML file")
	command.Flags().StringVar(&repository, "repository", ".", "Repository output directory")
	command.Flags().StringVar(&bendGenerator, "bend-generator", "", "Use a Bend generation executable")
	return command
}
