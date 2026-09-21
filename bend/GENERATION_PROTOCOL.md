# Generation input protocol

The future CLI adapter can pass a validated Harness IR to Bend without making
Bend understand YAML. The input is UTF-8 text with one tab-separated record per
line. Tabs and newlines in values must be rejected by the adapter.

```text
agent\tcodex
project\tmy-project
rule\tapproved\trule-id\tDescription
command\tgo test ./...
skill\treview\tReview changes\tskills/review.md
```

The first `agent` and `project` records are required. `rule` records use the
status values `candidate`, `approved`, or `rejected`; only approved rules are
rendered. Commands and skills are optional and preserve input order. Unknown
record types, duplicate required headers, malformed fields, and invalid Harness
IR must fail before rendering.

The Go side may produce this protocol while the Bend side owns validation and
rendering. Once the adapter and parser are integrated, the Go Markdown renderer
can be removed from the fork.
