package infrastructure

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// RunBendGenerator executes a configured Bend generator with a protocol file.
// The executable is supplied by the caller so the Go layer stays an adapter.
func RunBendGenerator(ctx context.Context, executable string, protocol string) ([]byte, error) {
	if strings.TrimSpace(executable) == "" {
		return nil, fmt.Errorf("Bend generator executable is required")
	}
	file, err := os.CreateTemp("", "harnessforge-generation-*.txt")
	if err != nil {
		return nil, err
	}
	name := file.Name()
	defer os.Remove(name)
	if _, err = file.WriteString(protocol); err != nil {
		file.Close()
		return nil, err
	}
	if err = file.Close(); err != nil {
		return nil, err
	}
	command := exec.CommandContext(ctx, executable, name)
	output, err := command.Output()
	if err != nil {
		if ctx.Err() != nil {
			return nil, ctx.Err()
		}
		return nil, fmt.Errorf("Bend generator failed: %w", err)
	}
	return output, nil
}
