import Base
import ./generation.bend as Generation
import ./harness.bend as Harness

# The first parser stage validates record shape without decoding YAML or doing IO.
def line_valid(+line: String) -> Bool:
  Bool.not(String.is_empty(line)) &&
    (String.starts_with(line, "agent\t") ||
      String.starts_with(line, "project\t") ||
      String.starts_with(line, "rule\t") ||
      String.starts_with(line, "command\t") ||
      String.starts_with(line, "skill\t"))

def protocol_valid(lines: List<&2, String>) -> Bool:
  match lines:
    case Nil{}:
      True{}
    case Con{head, tail}:
      line_valid(head) && protocol_valid(tail)

def two_field_value(parts: List<&2, String>) -> String:
  match parts:
    case Con{tag, Con{value, Nil{}}}:
      value
    case _:
      ""

def value(line: String) -> String:
  two_field_value(String.split(line, '\t'))

def rule_status(parts: List<&2, String>) -> String:
  match parts:
    case Con{tag, Con{status, Con{id, Con{description, Nil{}}}}}:
      status
    case _:
      ""

def rule_id(parts: List<&2, String>) -> String:
  match parts:
    case Con{tag, Con{status, Con{id, Con{description, Nil{}}}}}:
      id
    case _:
      ""

def rule_description(parts: List<&2, String>) -> String:
  match parts:
    case Con{tag, Con{status, Con{id, Con{description, Nil{}}}}}:
      description
    case _:
      ""

def rule_field(line: String) -> String:
  rule_status(String.split(line, '\t'))

def command_value(line: String) -> String:
  value(line)

def skill_id(parts: List<&2, String>) -> String:
  match parts:
    case Con{tag, Con{id, Con{description, Con{path, Nil{}}}}}:
      id
    case _:
      ""

def skill_description(parts: List<&2, String>) -> String:
  match parts:
    case Con{tag, Con{id, Con{description, Con{path, Nil{}}}}}:
      description
    case _:
      ""

def skill_path(parts: List<&2, String>) -> String:
  match parts:
    case Con{tag, Con{id, Con{description, Con{path, Nil{}}}}}:
      path
    case _:
      ""

def input_from_headers(agent: String, project: String) -> Generation.Input:
  Generation.Input{agent, project, Nil{}, Nil{}, Nil{}}

def approved_rule(+parts: List<&2, String>) -> Harness.Rule:
  Harness.Rule{rule_id(parts), rule_description(parts), Harness.Human{}, Harness.Approved{}, Nil{}}
