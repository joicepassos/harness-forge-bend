import Base
import ./core.bend as Core
import ./harness.bend as Harness

# A missing signal cannot increase a count; a match adds exactly one.
law absent_preserves_count:
  for n: Nat
  {Core.increment(False{}, n) == n : Nat}

law present_adds_one:
  for n: Nat
  {Core.increment(True{}, n) == 1n+n : Nat}

# An empty inventory never invents evidence, for any detection rule.
law empty_has_no_matches:
  for rule: Core.Rule
  {Core.count(Nil{}, rule) == 0n : Nat}

law empty_has_no_files:
  {Core.files(Nil{}) == 0n : Nat}

# Harness IR laws: AI rules must carry evidence, IDs are unique, and decisions
# can only be reversed by returning to Candidate.
law ai_rule_requires_evidence:
  {Harness.valid(Harness.Harness{1, "demo", [Harness.Rule{"ai", "Keep migrations reviewed", Harness.AI{}, Harness.Approved{}, Nil{}}]}) == False{} : Bool}

law human_rule_may_have_no_evidence:
  {Harness.valid(Harness.Harness{1, "demo", [Harness.Rule{"human", "Keep migrations reviewed", Harness.Human{}, Harness.Approved{}, Nil{}}]}) == True{} : Bool}

law duplicate_rule_ids_are_invalid:
  {Harness.valid(Harness.Harness{1, "demo", [Harness.Rule{"same", "First", Harness.Human{}, Harness.Candidate{}, Nil{}}, Harness.Rule{"same", "Second", Harness.Human{}, Harness.Candidate{}, Nil{}}]}) == False{} : Bool}

law approved_can_only_reopen:
  {Harness.transition_allowed(Harness.Approved{}, Harness.Rejected{}) == False{} : Bool}

law approved_reopens_as_candidate:
  {Harness.transition_allowed(Harness.Approved{}, Harness.Candidate{}) == True{} : Bool}

law generated_rules_are_approved_only:
  {Harness.approved_rules([Harness.Rule{"a", "A", Harness.Human{}, Harness.Approved{}, Nil{}}, Harness.Rule{"b", "B", Harness.Human{}, Harness.Candidate{}, Nil{}}, Harness.Rule{"c", "C", Harness.Human{}, Harness.Rejected{}, Nil{}}]) == 1n : Nat}
