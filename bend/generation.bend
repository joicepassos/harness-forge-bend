import Base
import ./harness.bend as Harness

type QualityGate is Data:
  QualityGate{command: String}

type Skill is Data:
  Skill{id: String, description: String, path: String}

type Input is Data:
  Input{agent: String, project: String, rules: List<&2, Harness.Rule>, commands: List<&2, QualityGate>, skills: List<&2, Skill>}

def input_valid(input: Input) -> Bool:
  match input:
    case Input{+agent, +project, rules, commands, skills}:
      (String.eq(agent, "codex") || String.eq(agent, "claude")) &&
        Bool.not(String.is_empty(String.trim(project))) &&
        Harness.valid(Harness.Harness{1, project, rules})

# Pure instruction generation. File writes and agent-specific paths stay outside Bend.
def status_line(status: Harness.Status) -> String:
  match status:
    case Harness.Approved{}:
      "approved"
    case Harness.Candidate{}:
      "candidate"
    case Harness.Rejected{}:
      "rejected"

def render_rule(rule: Harness.Rule) -> String:
  match rule:
    case Harness.Rule{id, description, origin, status, evidence}:
      "- **" ++ id ++ "** — " ++ description ++ "\n"

def render_approved(rules: List<&2, Harness.Rule>) -> String:
  match rules:
    case Nil{}:
      ""
    case Con{head, tail}:
      match head:
        case Harness.Rule{id, description, origin, Harness.Approved{}, evidence}:
          render_rule(head) ++ render_approved(tail)
        case Harness.Rule{id, description, origin, Harness.Candidate{}, evidence}:
          render_approved(tail)
        case Harness.Rule{id, description, origin, Harness.Rejected{}, evidence}:
          render_approved(tail)

def instructions(agent: String, rules: List<&2, Harness.Rule>) -> String:
  "# HarnessForge instructions for " ++ agent ++ "\n\n" ++ render_approved(rules)

def render_commands(commands: List<&2, QualityGate>) -> String:
  match commands:
    case Nil{}: ""
    case Con{head, tail}:
      match head:
        case QualityGate{command}:
          "- `" ++ command ++ "`\n" ++ render_commands(tail)

def render_skills(skills: List<&2, Skill>) -> String:
  match skills:
    case Nil{}: ""
    case Con{head, tail}:
      match head:
        case Skill{id, description, path}:
          "- [" ++ id ++ "] " ++ description ++ " — `" ++ path ++ "`\n" ++ render_skills(tail)

def instruction_document(agent: String, rules: List<&2, Harness.Rule>, commands: List<&2, QualityGate>, skills: List<&2, Skill>) -> String:
  instructions(agent, rules) ++ render_commands(commands) ++ render_skills(skills)

def render_input(input: Input) -> String:
  match input:
    case Input{agent, project, rules, commands, skills}:
      "# " ++ project ++ " agent instructions\n\n" ++
        render_approved(rules) ++
        render_commands(commands) ++
        render_skills(skills)

def approved_only(+rules: List<&2, Harness.Rule>) -> Bool:
  String.is_empty(render_approved(rules)) || Nat.is_gt(Harness.approved_rules(rules), 0n)
