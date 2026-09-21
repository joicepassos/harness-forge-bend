import Base
import ./core.bend as Core
import ./collector.bend as Collector

def nonempty(paths: List<&2, String>) -> List<&2, String>:
  match paths:
    case Nil{}:
      Nil{}
    case Con{+path, rest}:
      Core.keep(Collector.allowed_path(path), path, nonempty(rest))

# The manifest is UTF-8. Verify its byte count before emitting any output.
def choose(test: Bool, yes: Nat, no: Nat) -> Nat:
  match test:
    case True{}:
      yes
    case False{}:
      no

def char_bytes(+code: U32) -> Nat:
  choose((code < 128 : U32), 1n, choose((code < 2048 : U32), 2n, choose((code < 65536 : U32), 3n, 4n)))

def byte_count(text: String) -> Nat:
  match text:
    case SNil{}:
      0n
    case SCon{char, rest}:
      Nat.add(char_bytes(Char.to_u32(char)), byte_count(rest))

def render(complete: Bool, text: String) -> IO(Unit):
  match complete:
    case True{}:
      IO.write(Core.report(nonempty(String.lines(text))))
    case False{}:
      IO.die(Unit, 1, "Incomplete or invalid UTF-8 inventory")

def finish(pair: File & Result<&1, &1, U32 & String, String>, expected: U32) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    File.close(file)
    +text : String <- IO.pass(String, result)
    render(Nat.is_eq(byte_count(text), U32.to_nat(expected)), text)

def read(too_large: Bool, file: File, +size: U32) -> IO(Unit):
  match too_large:
    case True{}:
      do IO<Unit>:
        File.close(file)
        IO.die(Unit, 1, "Inventory exceeds 4 MiB")
    case False{}:
      do IO<Unit>:
        pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, 4194305)
        finish(pair, size)

def sized(pair: File & Result<&1, &1, U32 & String, U32>) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    +size : U32 <- IO.pass(U32, result)
    read((size > 4194304 : U32), file, size)

def analyze(path: String) -> IO(Unit):
  do IO<Unit>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
    sized(pair)

def usage(args: List<String>) -> IO(Unit):
  match args:
    case Con{path, Nil{}}:
      analyze(path)
    case _:
      IO.die(Unit, 2, "Usage: harnessforge-bend-core INVENTORY_FILE")

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    usage(args)
