import json
from googletrans import Translator

translator = Translator()

with open('lib/languages/app_en.arb', 'r', encoding='utf-8') as f:
    data = json.load(f)

it_data = {"@@locale": "it"}

for key, value in data.items():
    if key.startswith("@"):  # meta info
        it_data[key] = value
    else:
        it_data[key] = translator.translate(value, src='en', dest='it').text

with open('lib/languages/app_it.arb', 'w', encoding='utf-8') as f:
    json.dump(it_data, f, ensure_ascii=False, indent=2)