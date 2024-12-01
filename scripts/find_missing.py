import os

# Get list of downloaded files
files = os.listdir("Resources/Audio")

# Extract hymn numbers from filenames
downloaded_numbers = set()
for file in files:
    if file.startswith("en_") and file.endswith(".mp3"):
        num = int(file[3:-4])  # Remove "en_" and ".mp3"
        downloaded_numbers.add(num)

# Find missing numbers
missing = []
for i in range(1, 696):  # SDA Hymnal has 695 hymns
    if i not in downloaded_numbers:
        missing.append(i)

print(f"\nMissing hymn numbers ({len(missing)}):")
print(sorted(missing))
