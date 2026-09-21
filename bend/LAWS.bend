import Base
import ./core.bend as Core
import ./harness.bend as Harness
import ./generation.bend as Generation
import ./collector.bend as Collector
import ./protocol.bend as Protocol

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

law instructions_contain_approved_rules:
  {Generation.instructions("codex", [Harness.Rule{"approved", "A", Harness.Human{}, Harness.Approved{}, Nil{}}, Harness.Rule{"candidate", "C", Harness.Human{}, Harness.Candidate{}, Nil{}}]) == "# HarnessForge instructions for codex\n\n- **approved** — A\n" : String}

law instructions_are_empty_without_approval:
  {Generation.instructions("codex", [Harness.Rule{"candidate", "C", Harness.Human{}, Harness.Candidate{}, Nil{}}, Harness.Rule{"rejected", "R", Harness.Human{}, Harness.Rejected{}, Nil{}}]) == "# HarnessForge instructions for codex\n\n" : String}

law instruction_document_renders_edge_sections:
  {Generation.instruction_document("codex", Nil{}, [Generation.QualityGate{"go test ./..."}], [Generation.Skill{"review", "Review changes", "skills/review.md"}]) == "# HarnessForge instructions for codex\n\n- `go test ./...`\n- [review] Review changes — `skills/review.md`\n" : String}

law generation_input_requires_supported_agent:
  {Generation.input_valid(Generation.Input{"unknown", "demo", Nil{}, Nil{}, Nil{}}) == False{} : Bool}

law generation_input_accepts_valid_ir:
  {Generation.input_valid(Generation.Input{"codex", "demo", Nil{}, Nil{}, Nil{}}) == True{} : Bool}

law generation_renders_valid_input:
  {Generation.render_input(Generation.Input{"codex", "demo", [Harness.Rule{"approved", "A", Harness.Human{}, Harness.Approved{}, Nil{}}], Nil{}, Nil{}}) == "# demo agent instructions\n\n- **approved** — A\n" : String}

law collector_excludes_secret_names:
  {Collector.allowed_path(".env.local") == False{} : Bool}

law collector_prunes_dependency_directories:
  {Collector.skipped_directory("node_modules") == True{} : Bool}

law collector_keeps_source_directories:
  {Collector.skipped_directory("src") == False{} : Bool}

law inventory_limit_accepts_small_projects:
  {Core.within_file_limit(["README.md", "main.go"]) == True{} : Bool}

law generation_protocol_accepts_known_records:
  {Protocol.protocol_valid(["agent\tcodex", "project\tdemo", "command\tgo test ./..."]) == True{} : Bool}

law generation_protocol_rejects_unknown_records:
  {Protocol.protocol_valid(["unknown\tvalue"]) == False{} : Bool}
