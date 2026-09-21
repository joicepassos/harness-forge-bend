import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from scan import collect


class CollectorTests(unittest.TestCase):
    def test_inventory_and_exclusions(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for name in ['src/z.go', 'src/a_test.go', 'web/package.json',
                         'README.md', '.github/workflows/check.yml',
                         'node_modules/dependency/index.js', '.git/config',
                         '.env', '.env.local', 'private.pem']:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('contents must not be read', encoding='utf-8')
            with patch.object(Path, 'read_text', side_effect=AssertionError('content read')):
                manifest, skipped = collect(root)
            self.assertEqual(manifest, '.env\n.env.local\n.github/workflows/check.yml\nREADME.md\nprivate.pem\nsrc/a_test.go\nsrc/z.go\nweb/package.json\n')
            self.assertEqual(skipped, 2)

    def test_empty_and_invalid_root(self):
        with tempfile.TemporaryDirectory() as temp:
            self.assertEqual(collect(Path(temp)), ('', 0))
            file = Path(temp) / 'file'
            file.touch()
            with self.assertRaises(ValueError):
                collect(file)
            with self.assertRaises(OSError):
                collect(Path(temp) / 'missing')

    def test_limits_are_errors(self):
        with tempfile.TemporaryDirectory() as temp:
            (Path(temp) / 'a.go').touch()
            with patch('scan.MAX_FILES', 0), self.assertRaises(ValueError):
                collect(Path(temp))
            with patch('scan.MAX_BYTES', 1), self.assertRaises(ValueError):
                collect(Path(temp))

    @unittest.skipIf(os.name == 'nt', 'POSIX filesystem cases')
    def test_links_special_files_and_unicode(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'olá.py').touch()
            (root / 'line\nbreak.go').touch()
            (root / 'link').symlink_to('/etc')
            (root / 'file-link').symlink_to(root / 'olá.py')
            os.mkfifo(root / 'pipe')
            self.assertEqual(collect(root), ('olá.py\n', 4))
            with self.assertRaises(ValueError):
                collect(root / 'link')


if __name__ == '__main__':
    unittest.main()
