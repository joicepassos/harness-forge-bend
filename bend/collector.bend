import Base

# Pure inventory policy. Filesystem traversal remains an adapter until Bend's
# platform effects can provide bounded directory walking.
def skipped_directory(+name: String) -> Bool:
  String.eq(name, ".git") || String.eq(name, ".hg") || String.eq(name, ".svn") ||
    String.eq(name, "node_modules") || String.eq(name, "vendor") ||
    String.eq(name, ".venv") || String.eq(name, "venv") ||
    String.eq(name, "__pycache__") || String.eq(name, ".cache") ||
    String.eq(name, ".gocache") || String.eq(name, ".worktrees") ||
    String.eq(name, "dist") || String.eq(name, "build") ||
    String.eq(name, "target") || String.eq(name, ".next") ||
    String.eq(name, ".idea") || String.eq(name, ".vscode")

def secret_name(+name: String) -> Bool:
  String.starts_with(String.to_lower(name), ".env") || String.eq(String.to_lower(name), "credentials") ||
    String.eq(String.to_lower(name), "credentials.json") || String.eq(String.to_lower(name), "secrets.json") ||
    String.eq(String.to_lower(name), "id_rsa") || String.eq(String.to_lower(name), "id_ed25519") ||
    String.eq(String.to_lower(name), ".npmrc") || String.eq(String.to_lower(name), ".pypirc") ||
    String.ends_with(String.to_lower(name), ".pem") || String.ends_with(String.to_lower(name), ".key") ||
    String.ends_with(String.to_lower(name), ".p12") || String.ends_with(String.to_lower(name), ".pfx") ||
    String.ends_with(String.to_lower(name), ".keystore")

def allowed_path(+path: String) -> Bool:
  Bool.not(String.is_empty(path)) && Bool.not(secret_name(path))
