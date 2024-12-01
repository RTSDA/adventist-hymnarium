import os
import requests
from tqdm import tqdm
import time
import random

def download_hymn(hymn_number, output_dir):
    hymn_number_str = str(hymn_number).zfill(3)
    output_path = os.path.join(output_dir, "1941", f"en_{hymn_number}.mp3")
    
    # Create 1941 directory if it doesn't exist
    os.makedirs(os.path.join(output_dir, "1941"), exist_ok=True)
    
    if os.path.exists(output_path):
        print(f"Hymn {hymn_number} already exists, skipping...")
        return True, None

    url = f"https://s3.us-east-2.wasabisys.com/hymnalstorage/english/1941%20version/instrumental/{hymn_number_str}.mp3"

    try:
        print(f"Downloading hymn {hymn_number} from 1941 version...")
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        response = requests.get(url, headers=headers, stream=True)
        response.raise_for_status()
        
        # Get total file size for progress bar
        total_size = int(response.headers.get('content-length', 0))
        
        if total_size < 50000:  # If file is too small (likely an error page)
            print(f"File for hymn {hymn_number} seems too small, might be an error page")
            return False, "File too small"
            
        with open(output_path, 'wb') as f, tqdm(
            desc=f"Hymn {hymn_number}",
            total=total_size,
            unit='iB',
            unit_scale=True,
            unit_divisor=1024,
        ) as pbar:
            for data in response.iter_content(chunk_size=1024):
                size = f.write(data)
                pbar.update(size)
        
        return True, None
        
    except requests.exceptions.RequestException as e:
        print(f"Error downloading hymn {hymn_number}: {str(e)}")
        if os.path.exists(output_path):
            os.remove(output_path)
        return False, str(e)

def main():
    output_dir = "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio"
    
    # Download hymns 696-703
    for hymn_number in range(696, 704):
        success, error = download_hymn(hymn_number, output_dir)
        if not success:
            print(f"Failed to download hymn {hymn_number}: {error}")
        # Add a small delay between downloads
        time.sleep(random.uniform(1, 3))

if __name__ == "__main__":
    main()
