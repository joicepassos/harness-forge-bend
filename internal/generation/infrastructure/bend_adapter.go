package infrastructure

import (
	"context"
	"fmt"

	"harnessforge/internal/generation/domain"
	harnessdomain "harnessforge/internal/harness/domain"
)

// BendMarkdown adapts the existing generation port to the Bend runtime.
// The executable is injected so callers can choose a pinned native generator.
type BendMarkdown struct {
	Executable string
	Agent      string
}

func (b BendMarkdown) Render(input domain.Input) (domain.Document, error) {
	rules := make([]harnessdomain.Rule, 0, len(input.Rules))
	for _, rule := range input.Rules {
		rules = append(rules, harnessdomain.Rule{ID: rule.ID, Description: rule.Description, Status: "approved"})
	}
	skills := make([]harnessdomain.Skill, 0, len(input.Skills))
	for _, skill := range input.Skills {
		skills = append(skills, harnessdomain.Skill{ID: skill.ID, Description: skill.Description, Path: skill.Path, Status: "approved"})
	}
	gates := make([]harnessdomain.QualityGate, 0, len(input.Commands))
	for i, command := range input.Commands {
		gates = append(gates, harnessdomain.QualityGate{ID: fmt.Sprintf("gate-%d", i), Command: command})
	}
	protocol, err := EncodeProtocol(harnessdomain.Harness{
		Project:      harnessdomain.Project{Name: input.Project},
		Rules:        rules,
		Skills:       skills,
		QualityGates: gates,
	}, b.Agent)
	if err != nil {
		return domain.Document{}, err
	}
	content, err := RunBendGenerator(context.Background(), b.Executable, protocol)
	if err != nil {
		return domain.Document{}, err
	}
	path := "AGENTS.md"
	if b.Agent == "claude" {
		path = "CLAUDE.md"
	}
	return domain.Document{Path: path, Content: content}, nil
}
