import json
import os

# Read the original JSON file
input_path = '/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/old-hymnal-en.json'
output_path = '1941_hymnal.json'

with open(input_path, 'r', encoding='utf-8') as f:
    hymns = json.load(f)

# Transform the data into the format we need
transformed_hymns = []
for hymn in hymns:
    # Split content into verses
    content = hymn['content']
    verses = [verse.strip() for verse in content.split('\n\n') if verse.strip()]
    
    transformed_hymn = {
        'number': hymn['number'],
        'title': hymn['title'],
        'verses': verses
    }
    transformed_hymns.append(transformed_hymn)

# Save the transformed data
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(transformed_hymns, f, indent=2, ensure_ascii=False)

print(f"Successfully created {output_path} with {len(transformed_hymns)} hymns")
