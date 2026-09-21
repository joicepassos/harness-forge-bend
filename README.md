# HarnessForge Bend

[![Bend core](https://github.com/joicepassos/harness-forge-bend/actions/workflows/bend.yml/badge.svg)](https://github.com/joicepassos/harness-forge-bend/actions/workflows/bend.yml)

An incremental experiment porting the analysis core of [HarnessForge](https://github.com/joicepassos/harness-forge) to [Bend 2](https://bend-lang.com/), targeting **Linux and macOS**.

It analyzes project file names and produces a Markdown report with languages, build manifests, test signals, and evidence. The analyzed project is never modified, and no project command is executed.

## Getting started

Install Git, Bun 1.3.14, Node 24, Python 3.12+, and Clang 14+.

```sh
git clone https://github.com/joicepassos/harness-forge-bend.git
cd harness-forge-bend
sh bend/build.sh
python3 bend/scan.py /path/to/project > /tmp/report.md
```

The build pins the official Bend compiler, checks four laws, runs the tests, and produces a native binary. After the build, analysis only needs Python and the Bend binary.

## What is included

- **Bend:** classification, counting, evidence selection, report rendering, and the CLI that consumes the inventory.
- **Python:** a small filesystem adapter that applies exclusions and limits.
- **Validation:** core tests, collector tests, and native integration tests on Linux and macOS.

This is not a complete port yet. It does not include AI, content or AST analysis, or `.gitignore` interpretation. Instruction generation now has a validated Bend IR and an opt-in Go adapter; the full protocol parser is still incremental. The laws cover counting and IR properties; they are not a proof of the whole application. See the [0.1 increment guide](bend/README.md) for scope, limits, and next steps.

The original history and Go implementation remain available as reference. The new implementation lives under `bend/`; inherited installers and the npm package belong to the Go project. The [archived upstream README](docs/UPSTREAM_README.md) provides that context.

Licensed under [MIT](LICENSE).
