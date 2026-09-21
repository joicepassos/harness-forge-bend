package infrastructure

import (
	"fmt"
	"strings"

	harnessdomain "harnessforge/internal/harness/domain"
)

// EncodeProtocol is the narrow Go-to-Bend boundary. It serializes only the
// validated Harness data needed by generation; YAML and Markdown stay outside
// the Bend core.
func EncodeProtocol(h harnessdomain.Harness, agent string) (string, error) {
	if agent != "codex" && agent != "claude" {
		return "", fmt.Errorf("unsupported agent %q", agent)
	}
	lines := []string{"agent\t" + agent, "project\t" + h.Project.Name}
	for _, rule := range h.Rules {
		if rule.Status != "approved" {
			continue
		}
		lines = append(lines, "rule\tapproved\t"+rule.ID+"\t"+rule.Description)
	}
	for _, gate := range h.QualityGates {
		lines = append(lines, "command\t"+gate.Command)
	}
	for _, skill := range h.Skills {
		if skill.Status == "approved" && skill.Path != "" {
			lines = append(lines, "skill\t"+skill.ID+"\t"+skill.Description+"\t"+skill.Path)
		}
	}
	for _, line := range lines {
		if strings.ContainsAny(line, "\r\n") {
			return "", fmt.Errorf("generation protocol contains a newline")
		}
	}
	return strings.Join(lines, "\n") + "\n", nil
}
