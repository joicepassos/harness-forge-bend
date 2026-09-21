<p align="center">
  <img src="assets/branding/harnessforge-logo-v1.png" width="180" alt="HarnessForge logo">
</p>

<h1 align="center">HarnessForge</h1>

<p align="center">
  Build trustworthy AI workflows for your codebase.
</p>

<p align="center">
  <a href="https://github.com/joicepassos/harness-forge/actions/workflows/ci.yml"><img src="https://github.com/joicepassos/harness-forge/actions/workflows/ci.yml/badge.svg" alt="Checks"></a>
  <a href="https://github.com/joicepassos/harness-forge/releases"><img src="https://img.shields.io/github/v/release/joicepassos/harness-forge?display_name=tag" alt="Latest release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
</p>

HarnessForge is a CLI that understands your repository, turns reviewed rules into agent instructions, and keeps AI answers grounded in evidence you can inspect.

## Install

### npm

```sh
npm install -g harnessforge
harnessforge version
```

Starting with v1.1.1, the npm launcher downloads and verifies the release archive on first use, without an npm install script. The first `harnessforge` command may take a few seconds.

### Direct download

Download a pinned release and install it.

```sh
curl -fsSLO https://github.com/joicepassos/harness-forge/releases/download/v1.1.1/install.sh
sh install.sh --version 1.1.1 --install-dir "$HOME/.local/bin"
```

For Windows, use the inspected PowerShell installer:

```powershell
$Version = '1.1.1'
Invoke-WebRequest "https://github.com/joicepassos/harness-forge/releases/download/v$Version/install.ps1" -OutFile .\install-harnessforge.ps1
Get-Content .\install-harnessforge.ps1
.\install-harnessforge.ps1 -Version $Version -InstallDir "$env:USERPROFILE\bin"
$env:Path = "$env:USERPROFILE\bin;$env:Path"
harnessforge version
```

Release binaries support macOS and Linux (`amd64`, `arm64`) and Windows (`amd64`). See [Installation](docs/INSTALLATION.md) for manual downloads, updates, and troubleshooting.

## Terminal appearance

HarnessForge uses the blue and orange of its anvil logo in interactive terminal output. The help screen starts with `⚒ HarnessForge`; `init` and its `install` alias highlight each guided setup step. For example:

```text
[HF] HarnessForge
HarnessForge setup
Project: /path/to/project

Analyzing project...
```

The example shows the plain-text form. Piped output, `NO_COLOR=1`, and `CLICOLOR=0` omit terminal colors. Set `HARNESSFORGE_ASCII=1` to use ASCII status symbols in a colored terminal. JSON output remains undecorated.

## Get started

Open a terminal in the repository you want to configure:

```sh
cd /path/to/project
harnessforge init
```

The guided `init` analyzes the project, shows its findings, asks for additional documents and observations, and offers an AI-assisted proposal. The provider key is requested only if AI is selected and no key is already in the environment. It previews every file and requires confirmation before writing `.harness/harness.yaml`, agent instructions, or proposed skills. A local proposal remains available without an AI provider.

If `AGENTS.md` or `CLAUDE.md` already contains your team's instructions, the preview preserves them and shows the generated section that will be appended.

The npm package also exposes `harness-forge init`. Existing `harnessforge install` and `harnessforge tui` commands lead to the same setup. Use v1.1.1 or newer for this guided workflow.

HarnessForge stores approved rules in `.harness/harness.yaml` and produces reproducible `AGENTS.md` or `CLAUDE.md` files.

## Why HarnessForge?

| | |
| --- | --- |
| **Understand before changing** | Analyze languages, conventions, Git metadata, files, and symbols without modifying the project. |
| **Review the rules** | Keep agent guidance in ordinary YAML that your team can approve in code review. |
| **Use AI with evidence** | Select bounded context, retrieve sources, and reject answers with unsupported citations. |

## Safe by design

- Provider keys are read at runtime and are never written to HarnessForge preferences or harness files.
- Sensitive paths, symlinks, binary files, and secret-like content are excluded from repository context.
- Plugins require explicit `--authorize` permission and do not receive provider credentials by default.

Read the [Security policy](SECURITY.md) before connecting a provider or executing a plugin.

## Learn more

- [Usage guide](docs/USAGE.md) — workflows, examples, and command map.
- [Tutorial completo em português](docs/TUTORIAL-PT-BR.md) — teste a instalação, o harness, a busca, a IA e plugins passo a passo.
- [Installation](docs/INSTALLATION.md) — verified installers and checksums.
- [Security policy](SECURITY.md) — BYOK, data flow, and plugin boundaries.
- [Contributing](CONTRIBUTING.md) — develop and contribute.

HarnessForge is open source under the [MIT License](LICENSE).
