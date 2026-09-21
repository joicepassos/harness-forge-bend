import Base
import ./core.bend as Core

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
