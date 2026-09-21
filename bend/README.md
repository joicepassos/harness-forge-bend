# HarnessForge Bend — increment 0.1

A small analysis core for [HarnessForge](https://github.com/joicepassos/harness-forge), targeting **Linux and macOS** and written in [Bend 2](https://bend-lang.com/).

`core.bend` receives an inventory of relative paths, identifies languages, build manifests, and test or infrastructure signals, counts matches, and emits Markdown with up to three evidence files per signal. `scan.py` only walks directories and passes the inventory to the Bend executable. It never opens project files to read their contents.

## Run it

Requirements: Git, Bun 1.3.14, Node 24, Python 3.12+, and Clang 14+. On macOS, install Xcode command line tools; on Ubuntu, install `clang` through the package manager.

```sh
git clone https://github.com/joicepassos/harness-forge-bend.git
cd harness-forge-bend
sh bend/build.sh
python3 bend/scan.py /path/to/project > /tmp/report.md
```

The build downloads the official compiler into `.cache/bend`, pinned to commit `75cb8f3e041aeaad2b37e726c0a33ba19dc49df8` (Bend 2.0.23), checks the laws, runs the tests, and builds `bend/bin/harnessforge-bend-core`. Use `BEND_SOURCE=/path/to/bend sh bend/build.sh` to reuse a checkout at the same commit. Keep the report outside the analyzed project so it is not included in a later inventory.

## Bend conventions used here

The core is pure Bend code. `Rule` is declared `is Data` because rules are reused while scanning a path list; path lists are also `Data`. The report renderer uses recursive definitions and exhaustive `match` cases. `LAWS.bend` keeps human-owned properties separate from `PROOF.bend`, which contains the checked implementations. Run `bend PROOF.bend` before committing changes to the core.

The filesystem boundary is intentionally small and explicit: `scan.py` emits one UTF-8 relative path per line, and `main.bend` reads that inventory through the standard `File` and `IO` effects. The boundary does not execute anything found in the analyzed project.

`collector.bend` owns the pure path policy used by `main.bend`. The Python
adapter only walks directories, rejects symlinks and special files, and enforces
resource limits needed during traversal; it does not decide which file names
are safe to analyze.

`harness.bend` now models a pure Harness IR subset with tagged `Origin`, `Status`,
`Evidence`, `Rule`, and `Harness` values. It validates version, project name,
rule descriptions, AI evidence requirements, and duplicate IDs. Review transitions
are explicit: an approved or rejected rule can return to `Candidate`, but cannot
jump directly to the other decision. `approved_rules` is the first generation
boundary: later document generation can consume only approved rules.

`generation.bend` is the next pure boundary. It renders deterministic Markdown
instructions from the IR and filters candidate or rejected rules before output.
The corresponding laws in `LAWS.bend` and proofs in `PROOF.bend` ensure that an
instruction document contains approved rules only, and is empty when no rule is
approved.

The Go CLI can opt into the Bend generation adapter with
`harnessforge generate codex --bend-generator /path/to/generator`. The executable
receives the protocol described in `GENERATION_PROTOCOL.md` as its only argument
and must write the generated document to standard output.

## Rules in this increment

- Languages by extension: Bend, Go, Python, Java, TypeScript/TSX, JavaScript/JSX, Rust, C, and Shell. Matching is case-sensitive.
- Build manifests by file name, including subprojects: Go modules, npm-compatible, Python packaging, Cargo, Maven, Gradle, and Make.
- Signals: Go test files, a root `tests/` directory, Dockerfile, root GitHub Actions workflows, `README.md`, and `AGENTS.md`.
- Deterministic ordering and escaped paths in Markdown tables.
- Symlinks, special files, dependency directories, caches, and selected secret-like names such as `.env*` and private keys are excluded.
- Limits: 20,000 files, 100,000 visited entries, depth 64, and a 4 MiB UTF-8 inventory. Exceeding a limit fails without emitting a partial report.

## Deliberate limitations

These are filename heuristics. There is no content or AST analysis, framework or dependency detection, Git history, AI, instruction generation, or Harness YAML validation. `.gitignore` is not interpreted. Ordinary binary files count, but their contents are never read. The exclusion list is not a secret scanner. Run against a stable tree; this version does not provide an atomic snapshot against concurrent changes. Pruned directories count as one excluded entry.

`LAWS.bend` and `PROOF.bend` check four focused properties: absence preserves a count, presence adds one, and empty inventories produce no files or matches. They do not formally verify the collector or the complete application. Tests cover detection, evidence, limits, exclusions, and native execution.

## Incremental roadmap

1. **Pure core:** rules, counting, evidence, report, and laws.
2. **Harness IR:** typed rules, validation, review transitions, and approval filtering.
3. **Real input:** bounded collector, Bend CLI, and integration tests.
4. **Linux/macOS validation:** pinned build and repository report in CI.

Possible next steps are `.gitignore` support, JSON output, and replacing the collector with a POSIX Bend effect. The inherited Go code remains the reference; this experiment does not claim full parity.
