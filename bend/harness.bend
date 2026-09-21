import Base

# A typed, pure subset of the Harness IR. IO and YAML decoding stay at the boundary.
type Origin is Data:
  Human{}
  AI{}

type Status is Data:
  Candidate{}
  Approved{}
  Rejected{}

type Evidence is Data:
  Evidence{file: String, symbol: String, revision: String}

type Rule is Data:
  Rule{id: String, description: String, origin: Origin, status: Status, evidence: List<&2, Evidence>}

type Harness is Data:
  Harness{version: U32, project: String, rules: List<&2, Rule>}

def present(text: String) -> Bool:
  Bool.not(String.is_empty(String.trim(text)))

def has_evidence(evidence: List<&2, Evidence>) -> Bool:
  match evidence:
    case Nil{}:
      False{}
    case Con{head, tail}:
      True{}

def evidence_valid(evidence: List<&2, Evidence>) -> Bool:
  match evidence:
    case Nil{}:
      True{}
    case Con{head, tail}:
      match head:
        case Evidence{file, symbol, revision}:
          present(file) && evidence_valid(tail)

def origin_valid(origin: Origin, +evidence: List<&2, Evidence>) -> Bool:
  match origin:
    case Human{}:
      evidence_valid(evidence)
    case AI{}:
      has_evidence(evidence) && evidence_valid(evidence)

def status_valid(status: Status) -> Bool:
  match status:
    case Candidate{}:
      True{}
    case Approved{}:
      True{}
    case Rejected{}:
      True{}

def rule_valid(rule: Rule) -> Bool:
  match rule:
    case Rule{id, description, origin, status, evidence}:
      present(id) && present(description) && origin_valid(origin, evidence) && status_valid(status)

def contains_id(ids: List<&2, String>, +wanted: String) -> Bool:
  match ids:
    case Nil{}:
      False{}
    case Con{head, tail}:
      String.eq(head, wanted) || contains_id(tail, wanted)

def rules_valid(rules: List<&2, Rule>, +ids: List<&2, String>) -> Bool:
  match rules:
    case Nil{}:
      True{}
    case Con{head, tail}:
      match head:
        case Rule{+id, description, origin, status, evidence}:
          rule_valid(head) && Bool.not(contains_id(ids, id)) && rules_valid(tail, Con{id, ids})

def valid(harness: Harness) -> Bool:
  match harness:
    case Harness{version, project, rules}:
      U32.is_eq(version, 1) && present(project) && rules_valid(rules, Nil{})

def same_status(a: Status, b: Status) -> Bool:
  match a b:
    case Candidate{} Candidate{}:
      True{}
    case Approved{} Approved{}:
      True{}
    case Rejected{} Rejected{}:
      True{}
    case _ _:
      False{}

# Decisions are reversible only through Candidate, matching HarnessForge's review model.
def transition_allowed(from: Status, to: Status) -> Bool:
  match from to:
    case Candidate{} Candidate{}:
      True{}
    case Candidate{} Approved{}:
      True{}
    case Candidate{} Rejected{}:
      True{}
    case Approved{} Candidate{}:
      True{}
    case Rejected{} Candidate{}:
      True{}
    case Approved{} Approved{}:
      True{}
    case Rejected{} Rejected{}:
      True{}
    case _ _:
      False{}

def approved(rule: Rule) -> Bool:
  match rule:
    case Rule{id, description, origin, status, evidence}:
      match status:
        case Approved{}:
          True{}
        case _:
          False{}

def approved_rules(rules: List<&2, Rule>) -> Nat:
  match rules:
    case Nil{}:
      0n
    case Con{head, tail}:
      match head:
        case Rule{id, description, origin, Approved{}, evidence}:
          Nat.add(1n, approved_rules(tail))
        case Rule{id, description, origin, Candidate{}, evidence}:
          approved_rules(tail)
        case Rule{id, description, origin, Rejected{}, evidence}:
          approved_rules(tail)
