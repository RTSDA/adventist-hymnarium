import os
import glob

def check_missing_files():
    base_path = "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985"
    
    # Get all existing mp3 files
    files = glob.glob(os.path.join(base_path, "*.mp3"))
    existing_numbers = set()
    
    for file_path in files:
        filename = os.path.basename(file_path)
        if filename.startswith("en_"):
            try:
                number = int(filename[3:-4])  # Remove 'en_' prefix and '.mp3' extension
                existing_numbers.add(number)
            except ValueError:
                print(f"Warning: Could not parse number from filename: {filename}")
    
    # Check for missing numbers (1985 hymnal has 695 hymns)
    missing = []
    for i in range(1, 696):
        if i not in existing_numbers:
            missing.append(i)
    
    if missing:
        print("\nMissing hymn numbers:")
        for num in missing:
            print(f"en_{num:03d}.mp3")
        print(f"\nTotal missing: {len(missing)} hymns")
    else:
        print("No missing hymns found!")

if __name__ == "__main__":
    check_missing_files()
