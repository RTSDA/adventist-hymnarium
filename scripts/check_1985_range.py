import os
import glob

def check_hymn_range():
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
    
    # Check for missing numbers in ranges
    print("\nMissing hymn numbers by range:")
    
    # Define ranges (e.g., 1-100, 101-200, etc.)
    ranges = [(1, 100), (101, 200), (201, 300), (301, 400), 
             (401, 500), (501, 600), (601, 695)]
    
    total_missing = 0
    for start, end in ranges:
        missing_in_range = []
        for i in range(start, end + 1):
            if i not in existing_numbers:
                missing_in_range.append(i)
        
        if missing_in_range:
            print(f"\nRange {start}-{end}:")
            print(", ".join(f"{num:03d}" for num in missing_in_range))
            total_missing += len(missing_in_range)
    
    print(f"\nTotal missing: {total_missing} hymns")

if __name__ == "__main__":
    check_hymn_range()
