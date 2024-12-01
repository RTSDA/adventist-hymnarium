import os
import glob
import re

def pad_filenames():
    base_path = "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985"
    
    # Get all mp3 files in the directory
    files = glob.glob(os.path.join(base_path, "*.mp3"))
    
    for file_path in files:
        filename = os.path.basename(file_path)
        
        # Match files like en_1.mp3, en_2.mp3, etc.
        match = re.match(r'^en_(\d+)\.mp3$', filename)
        if match:
            number = match.group(1)
            if len(number) < 3:  # Only process if the number part is less than 3 digits
                # Pad with zeros
                new_number = number.zfill(3)
                new_filename = f"en_{new_number}.mp3"
                new_path = os.path.join(base_path, new_filename)
                
                if os.path.exists(new_path) and new_path != file_path:
                    print(f"Warning: {new_filename} already exists, skipping {filename}")
                    continue
                    
                print(f"Renaming {filename} to {new_filename}")
                os.rename(file_path, new_path)

if __name__ == "__main__":
    pad_filenames()
