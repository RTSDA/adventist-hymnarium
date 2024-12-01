import os
import glob

def rename_files():
    base_path = "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1941"
    
    # Get all mp3 files in the directory
    files = glob.glob(os.path.join(base_path, "*.mp3"))
    
    for file_path in files:
        filename = os.path.basename(file_path)
        if filename.startswith("en_"):
            # Extract the number from the filename
            number = filename[3:-4]  # Remove 'en_' prefix and '.mp3' extension
            # Create new filename with 'old_' prefix
            new_filename = f"old_{number}.mp3"
            new_path = os.path.join(base_path, new_filename)
            
            print(f"Renaming {filename} to {new_filename}")
            os.rename(file_path, new_path)

if __name__ == "__main__":
    rename_files()
