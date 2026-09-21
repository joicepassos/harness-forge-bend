# Bend reorganization plan

The fork can move the application toward a Bend-first architecture in small,
reviewable slices. The existing Go tree is grouped by responsibility so each
replacement has a clear boundary.

## Bend-owned layers

- `core.bend`: project inventory analysis and evidence counting.
- `harness.bend`: typed Harness IR, validation, and review transitions.
- `generation.bend`: deterministic instruction and report generation.
- `scan.bend` (next): filesystem inventory effects with explicit limits.
- `cli.bend` (later): command dispatch, exit codes, and text output.

## Remaining adapters

The first adapter can remain a small Python or Go launcher while Bend gains
filesystem and process effects. Network clients, GitHub integrations, LLM
providers, embeddings, and terminal UI should stay at the edge until Bend
effects cover their contracts.

## Go migration order

1. Replace `internal/generation` with `generation.bend` output.
2. Replace `internal/harness` domain validation with `harness.bend`.
3. Replace `internal/analyzer` with the bounded Bend collector and analysis.
4. Move configuration and discovery data types into Bend records.
5. Keep Go only as a compatibility launcher, then remove it when the Bend CLI
   has equivalent behavior and integration coverage.

Each step must keep the report format deterministic and pass the Bend laws,
native build, and integration tests before deleting the replaced Go package.
