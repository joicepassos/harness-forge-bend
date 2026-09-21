#!/usr/bin/env python3
"""Filesystem adapter. Detection and report rendering belong to core.bend."""
import argparse
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile

SKIP_DIRS = frozenset({
    '.git', '.hg', '.svn', 'node_modules', 'vendor', '.venv', 'venv',
    '__pycache__', '.cache', '.gocache', '.worktrees', 'dist', 'build',
    'target', '.next', '.idea', '.vscode', '.ssh', '.aws', '.azure',
})
def collect(root: Path) -> tuple[str, int]:
    """Return a sorted, bounded manifest without opening project files.

    Symlinks and special files are never followed. Concurrently changing trees
    are outside this v0.1 snapshot model; run against a stable checkout.
    """
    root = Path(os.path.abspath(root))
    if not stat.S_ISDIR(root.lstat().st_mode):
        raise ValueError('project must be a real directory, not a symlink')
    paths, skipped, visited = [], 0, 0
    pending = [(root, 0)]
    while pending:
        directory, depth = pending.pop()
        if depth > 64:
            raise ValueError('directory depth exceeds 64')
        with os.scandir(directory) as entries:
            for entry in entries:
                visited += 1
                if visited > 100_000:
                    raise ValueError('directory-entry limit exceeds 100000')
                name = entry.name
                relative = Path(entry.path).relative_to(root).as_posix()
                try:
                    relative.encode('utf-8', errors='strict')
                except UnicodeError:
                    skipped += 1
                    continue
                if (any(ord(c) < 32 or ord(c) == 127 for c in relative)
                        or entry.is_symlink()):
                    skipped += 1
                    continue
                if entry.is_dir(follow_symlinks=False):
                    if name in SKIP_DIRS:
                        skipped += 1
                    else:
                        pending.append((Path(entry.path), depth + 1))
                elif entry.is_file(follow_symlinks=False):
                    paths.append(relative)
                else:
                    skipped += 1
    return ''.join(path + '\n' for path in sorted(paths)), skipped


def main() -> int:
    parser = argparse.ArgumentParser(description='Analyze project file names with the Bend core.')
    parser.add_argument('project', type=Path)
    parser.add_argument('--core', type=Path, default=Path(__file__).parent / 'bin' / 'harnessforge-bend-core')
    args = parser.parse_args()
    try:
        manifest, skipped = collect(args.project)
        # No shell, no execution of anything discovered in the target project.
        with tempfile.TemporaryDirectory(prefix='harnessforge-bend-') as temp:
            source = Path(temp) / 'inventory.txt'
            source.write_bytes(manifest.encode('utf-8'))
            result = subprocess.run([str(args.core.resolve()), str(source)],
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        if result.returncode:
            sys.stderr.buffer.write(result.stderr)
            return result.returncode if result.returncode > 0 else 1
        sys.stdout.buffer.write(result.stdout)
        print(f'\nCollector: {skipped} entries excluded (each pruned directory counts once).')
        return 0
    except (OSError, ValueError) as error:
        print(f'harnessforge-bend: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
