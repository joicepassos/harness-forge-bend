"""Run after building the native Bend binary on Linux or macOS."""
from pathlib import Path
import os
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
CORE = HERE / 'bin' / 'harnessforge-bend-core'


class NativeTests(unittest.TestCase):
    def test_project_to_report(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for name in ['go.mod', 'main.go', 'main_test.go', 'olá.py', 'README.md']:
                (root / name).write_text('fixture\n')
            (root / '.env').write_text('not collected\n')
            before = {p.name: p.read_bytes() for p in root.iterdir()}
            result = subprocess.run([sys.executable, str(HERE / 'scan.py'), str(root)],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('Files inventoried: 5', result.stdout)
            self.assertIn('| Go | 2 |', result.stdout)
            self.assertIn('| Python | 1 | olá.py<br>', result.stdout)
            self.assertIn('| Go modules | 1 | go.mod<br>', result.stdout)
            self.assertIn('Collector: 0 entries excluded', result.stdout)
            self.assertNotIn('.env', result.stdout)
            self.assertEqual(before, {p.name: p.read_bytes() for p in root.iterdir()})

    def test_empty_and_oversized_inventory(self):
        with tempfile.TemporaryDirectory() as temp:
            manifest = Path(temp) / 'manifest.txt'
            manifest.touch()
            result = subprocess.run([str(CORE), str(manifest)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('Files inventoried: 0', result.stdout)
            manifest.write_bytes(b'x' * (4 * 1024 * 1024 + 1))
            result = subprocess.run([str(CORE), str(manifest)], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(result.stdout, '')
            self.assertIn('exceeds', result.stderr)

    def test_usage_and_missing_file(self):
        result = subprocess.run([str(CORE)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 2)
        with tempfile.TemporaryDirectory() as temp:
            result = subprocess.run([str(CORE), str(Path(temp) / 'missing')], capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(result.stdout, b'')


if __name__ == '__main__':
    unittest.main()
