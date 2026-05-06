import json
from pathlib import Path
data = json.loads(Path('data/questions.generated.json').read_text(encoding='utf-8'))
assert 'onboarding_intro' in data
assert 'onboarding' in data
assert 'cards' in data
assert len(data['cards']) == 22
for slug, positions in data['cards'].items():
    assert set(positions) == {'past', 'present', 'future'}
    for pos, section in positions.items():
        assert section.get('story')
        assert len(section.get('questions', [])) == 5
print('generated file schema ok')
Path('data/questions.json').write_text(Path('data/questions.generated.json').read_text(encoding='utf-8'), encoding='utf-8')
print('copied to data/questions.json')
data2 = json.loads(Path('data/questions.json').read_text(encoding='utf-8'))
assert data2 == data
print('questions.json fixed schema ok')
