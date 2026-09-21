package infrastructure

import (
	"testing"

	"harnessforge/internal/generation/domain"
)

func TestBendMarkdownRejectsUnsupportedAgentBeforeExecution(t *testing.T) {
	_, err := (BendMarkdown{Executable: "missing-generator", Agent: "unknown"}).Render(domain.Input{Project: "demo"})
	if err == nil {
		t.Fatal("expected unsupported agent error")
	}
}
