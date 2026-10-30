import pathlib, unittest, json
ROOT = pathlib.Path(__file__).resolve().parents[1]

class PublicReleaseChecks(unittest.TestCase):
    def test_mit_license_and_scope_notice(self):
        text = (ROOT / 'LICENSE').read_text('utf-8')
        self.assertTrue(text.startswith('MIT License'))
        self.assertIn('Copyright (c) 2026 XYN Persona System Contributors', text)
        self.assertIn('permission notice', text.lower())
        doc = (ROOT / 'docs/RELEASE-NOTES-v2.0.0-rc1.md').read_text('utf-8')
        self.assertIn('prerelease', doc.lower())
        self.assertIn('unverified', doc.lower())
    def test_no_memory_or_model_secrets_in_release_paths(self):
        manifest = json.loads((ROOT/'MANIFEST.json').read_text('utf-8'))
        for name in manifest:
            self.assertNotIn('MEMORY.md', name)
            self.assertFalse(name.endswith('/.env'))
            self.assertFalse(name.endswith('/auth.json'))

if __name__ == '__main__': unittest.main()
