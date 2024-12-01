import os
import glob
import re

def fix_filenames():
    base_path = "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985"
    
    # Get all mp3 files in the directory
    files = glob.glob(os.path.join(base_path, "*.mp3"))
    
    for file_path in files:
        filename = os.path.basename(file_path)
        
        # If it's already in the correct format (en_XXX.mp3), skip it
        if re.match(r'^en_\d{3}\.mp3$', filename):
            continue
            
        # If it's just numbers (like 037.mp3 or 424.mp3)
        if re.match(r'^\d+\.mp3$', filename):
            number = filename[:-4]  # Remove .mp3
            # Pad with zeros if needed
            number = number.zfill(3)
            new_filename = f"en_{number}.mp3"
            new_path = os.path.join(base_path, new_filename)
            
            # Check if the destination file already exists
            if os.path.exists(new_path):
                print(f"Warning: {new_filename} already exists, skipping {filename}")
                continue
                
            print(f"Renaming {filename} to {new_filename}")
            os.rename(file_path, new_path)
        else:
            print(f"Warning: Unexpected filename format: {filename}")

if __name__ == "__main__":
    fix_filenames()
