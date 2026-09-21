package infrastructure

import (
	"context"
	"errors"
	"testing"
)

func TestRunBendGeneratorHonorsCanceledContext(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	_, err := RunBendGenerator(ctx, "missing-generator", "agent\tcodex\n")
	if !errors.Is(err, context.Canceled) {
		t.Fatalf("expected context cancellation, got %v", err)
	}
}
