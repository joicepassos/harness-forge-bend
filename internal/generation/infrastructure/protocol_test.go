package infrastructure

import (
	"strings"
	"testing"

	harnessdomain "harnessforge/internal/harness/domain"
)

func TestEncodeProtocolFiltersUnapprovedData(t *testing.T) {
	got, err := EncodeProtocol(harnessdomain.Harness{
		Project: harnessdomain.Project{Name: "demo"},
		Rules: []harnessdomain.Rule{
			{ID: "approved", Description: "A", Status: "approved"},
			{ID: "candidate", Description: "C", Status: "candidate"},
		},
		QualityGates: []harnessdomain.QualityGate{{Command: "go test ./..."}},
		Skills: []harnessdomain.Skill{{ID: "review", Description: "Review", Path: "skills/review.md", Status: "approved"}},
	}, "codex")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(got, "rule\tapproved\tapproved\tA") || strings.Contains(got, "candidate") {
		t.Fatalf("unexpected protocol: %q", got)
	}
}

func TestEncodeProtocolRejectsControlSeparators(t *testing.T) {
	_, err := EncodeProtocol(harnessdomain.Harness{Project: harnessdomain.Project{Name: "bad\tname"}}, "codex")
	if err == nil {
		t.Fatal("expected tab in a field to be rejected")
	}
}
