import Base

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
