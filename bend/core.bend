import Base

# All detection is pure and based on relative file names, never file contents.
type Rule is Data:
  Suffix{label: String, pattern: String}
  Name{label: String, pattern: String}
  Prefix{label: String, pattern: String}

def basename(parts: List<&2, String>) -> String:
  match parts:
    case Nil{}:
      ""
    case Con{h, Nil{}}:
      h
    case Con{h, t}:
      basename(t)

def matches(rule: Rule, path: String) -> Bool:
  match rule:
    case Suffix{label, pattern}:
      String.ends_with(path, pattern)
    case Name{label, pattern}:
      String.eq(basename(String.split(path, '/')), pattern)
    case Prefix{label, pattern}:
      String.starts_with(path, pattern)

def label(rule: Rule) -> String:
  match rule:
    case Suffix{name, pattern}:
      name
    case Name{name, pattern}:
      name
    case Prefix{name, pattern}:
      name

def increment(found: Bool, count: Nat) -> Nat:
  match found:
    case False{}:
      count
    case True{}:
      1n+count

def count(paths: List<&2, String>, +rule: Rule) -> Nat:
  match paths:
    case Nil{}:
      0n
    case Con{path, rest}:
      increment(matches(rule, path), count(rest, rule))

def files(paths: List<&2, String>) -> Nat:
  match paths:
    case Nil{}:
      0n
    case Con{path, rest}:
      1n+files(rest)

def within_file_limit(paths: List<&2, String>) -> Bool:
  Bool.not(Nat.is_gt(files(paths), 20000n))

# Escape file names before including them in a Markdown table.
def escape(path: String) -> String:
  html = String.join(String.split(String.join(String.split(String.join(String.split(path, '&'), "&amp;"), '<'), "&lt;"), '>'), "&gt;")
  pipes = String.join(String.split(html, '|'), "&#124;")
  ticks = String.join(String.split(pipes, '`'), "&#96;")
  links = String.join(String.split(String.join(String.split(ticks, '['), "&#91;"), ']'), "&#93;")
  stars = String.join(String.split(String.join(String.split(links, '*'), "&#42;"), '_'), "&#95;")
  String.join(String.split(stars, '\\'), "&#92;")

def keep(found: Bool, path: String, rest: List<&2, String>) -> List<&2, String>:
  match found:
    case False{}:
      rest
    case True{}:
      Con{path, rest}

def evidence(paths: List<&2, String>, +rule: Rule) -> List<&2, String>:
  match paths:
    case Nil{}:
      Nil{}
    case Con{+path, rest}:
      keep(matches(rule, path), path, evidence(rest, rule))

def examples(paths: List<&2, String>, limit: Nat) -> String:
  match paths limit:
    case Nil{} _:
      ""
    case Con{path, rest} 0n:
      ""
    case Con{path, rest} 1n+n:
      escape(path) ++ "<br>" ++ examples(rest, n)

def row(total: Nat, name: String, evidence: String) -> String:
  match total:
    case 0n:
      ""
    case 1n+n:
      "| " ++ name ++ " | " ++ Nat.show(1n+n) ++ " | " ++ evidence ++ " |\n"

def rows(rules: List<&2, Rule>, +paths: List<&2, String>) -> String:
  match rules:
    case Nil{}:
      ""
    case Con{+rule, rest}:
      row(count(paths, rule), label(rule), examples(evidence(paths, rule), 3n)) ++ rows(rest, paths)

def language_rules() -> List<&2, Rule>:
  [Suffix{"Bend", ".bend"}, Suffix{"Go", ".go"}, Suffix{"Python", ".py"}, Suffix{"Java", ".java"}, Suffix{"TypeScript", ".ts"}, Suffix{"TSX", ".tsx"}, Suffix{"JavaScript", ".js"}, Suffix{"JSX", ".jsx"}, Suffix{"Rust", ".rs"}, Suffix{"C", ".c"}, Suffix{"Shell", ".sh"}]

def build_rules() -> List<&2, Rule>:
  [Name{"Go modules", "go.mod"}, Name{"npm-compatible", "package.json"}, Name{"Python packaging", "pyproject.toml"}, Name{"Cargo", "Cargo.toml"}, Name{"Maven", "pom.xml"}, Name{"Gradle", "build.gradle"}, Name{"Gradle Kotlin", "build.gradle.kts"}, Name{"Make", "Makefile"}]

def signal_rules() -> List<&2, Rule>:
  [Suffix{"Go test files", "_test.go"}, Prefix{"Test directory", "tests/"}, Name{"Docker", "Dockerfile"}, Prefix{"GitHub Actions", ".github/workflows/"}, Name{"Agent instructions", "AGENTS.md"}, Name{"Project README", "README.md"}]

def section(title: String, body: String) -> String:
  "## " ++ title ++ "\n\n| Signal | Matching files | Evidence (up to 3) |\n| --- | ---: | --- |\n" ++ body ++ "\n"

def report(+paths: List<&2, String>) -> String:
  languages builds = rows(language_rules(), paths) rows(build_rules(), paths)
  "# HarnessForge Bend — project report\n\nFiles inventoried: " ++ Nat.show(files(paths)) ++ "\n\n" ++ section("Languages", languages) ++ section("Build manifests", builds) ++ section("Project signals", rows(signal_rules(), paths)) ++ "## Scope and limitations\n\nFile-name heuristics only; evidence is not proof of a dependency, working build, or test coverage. Empty sections mean no matching files. No file contents, Git history, AI providers, or project commands are read or executed. Counts can overlap between sections.\n"
