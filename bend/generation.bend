import Base
import ./harness.bend as Harness

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

def approved_only(+rules: List<&2, Harness.Rule>) -> Bool:
  String.is_empty(render_approved(rules)) || Nat.is_gt(Harness.approved_rules(rules), 0n)
