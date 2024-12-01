import os
import glob

def check_file_468():
    base_path = "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985"
    target_file = "en_468.mp3"
    
    print(f"Checking for {target_file} in {base_path}")
    
    # List all files in the directory
    print("\nAll files containing '468':")
    all_files = os.listdir(base_path)
    for file in all_files:
        if "468" in file:
            full_path = os.path.join(base_path, file)
            print(f"Found: {file}")
            print(f"Full path: {full_path}")
            print(f"File exists: {os.path.exists(full_path)}")
            print(f"Is file: {os.path.isfile(full_path)}")
            try:
                size = os.path.getsize(full_path)
                print(f"File size: {size} bytes")
            except OSError as e:
                print(f"Error getting file size: {e}")

    # Try exact match
    exact_path = os.path.join(base_path, target_file)
    print(f"\nChecking exact path: {exact_path}")
    print(f"Exists: {os.path.exists(exact_path)}")
    
    # List all mp3 files
    print("\nAll .mp3 files in directory:")
    mp3_files = [f for f in all_files if f.endswith('.mp3')]
    mp3_files.sort()
    for file in mp3_files:
        if "46" in file:  # Show files around 468
            print(file)

if __name__ == "__main__":
    check_file_468()
