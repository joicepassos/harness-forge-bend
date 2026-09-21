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
	validate := func(value string) error {
		if strings.ContainsAny(value, "\t\r\n") {
			return fmt.Errorf("generation protocol field contains a tab or newline")
		}
		return nil
	}
	for _, value := range []string{agent, h.Project.Name} {
		if err := validate(value); err != nil {
			return "", err
		}
	}
	lines := []string{"agent\t" + agent, "project\t" + h.Project.Name}
	for _, rule := range h.Rules {
		if rule.Status != "approved" {
			continue
		}
		for _, value := range []string{rule.ID, rule.Description} {
			if err := validate(value); err != nil {
				return "", err
			}
		}
		lines = append(lines, "rule\tapproved\t"+rule.ID+"\t"+rule.Description)
	}
	for _, gate := range h.QualityGates {
		if err := validate(gate.Command); err != nil {
			return "", err
		}
		lines = append(lines, "command\t"+gate.Command)
	}
	for _, skill := range h.Skills {
		if skill.Status == "approved" && skill.Path != "" {
			for _, value := range []string{skill.ID, skill.Description, skill.Path} {
				if err := validate(value); err != nil {
					return "", err
				}
			}
			lines = append(lines, "skill\t"+skill.ID+"\t"+skill.Description+"\t"+skill.Path)
		}
	}
	return strings.Join(lines, "\n") + "\n", nil
}
