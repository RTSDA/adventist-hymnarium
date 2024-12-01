import os
import requests
import time
from tqdm import tqdm
import random

missing_hymns = []

def download_hymn(hymn_number, output_dir, max_retries=3):
    # Construct the filename
    hymn_number_str = str(hymn_number).zfill(3)
    output_path = os.path.join(output_dir, "1985", f"{hymn_number_str}.mp3")
    
    # Create 1985 directory if it doesn't exist
    os.makedirs(os.path.join(output_dir, "1985"), exist_ok=True)
    
    # Skip if file already exists
    if os.path.exists(output_path):
        print(f"Hymn {hymn_number} already exists, skipping...")
        return
    
    # Construct the URLs
    urls = [
        f"https://s3.us-east-2.wasabisys.com/hymnalstorage/english/1985%20version/instrumental/{hymn_number_str}.mp3",
        f"https://s3.us-east-2.wasabisys.com/hymnalstorage/english/1941%20version/instrumental/{hymn_number_str}.mp3"
    ]

    for url in urls:
        for attempt in range(max_retries):
            try:
                print(f"Downloading hymn {hymn_number} from {url} (attempt {attempt + 1}/{max_retries})")
                
                # Download the file
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                }
                response = requests.get(url, headers=headers, stream=True)
                response.raise_for_status()
                
                # Get total file size for progress bar
                total_size = int(response.headers.get('content-length', 0))
                
                if total_size < 50000:  # If file is too small (likely an error page)
                    print(f"Hymn {hymn_number} appears to have no audio available")
                    missing_hymns.append(hymn_number)
                    return
                
                # Save the file with progress bar
                with tqdm(total=total_size, unit='iB', unit_scale=True) as pbar:
                    with open(output_path, 'wb') as f:
                        for chunk in response.iter_content(chunk_size=8192):
                            if chunk:
                                size = f.write(chunk)
                                pbar.update(size)
                
                print(f"Successfully downloaded hymn {hymn_number}")
                # Random delay between 2-4 seconds to avoid rate limiting
                delay = 2 + random.random() * 2
                print(f"Waiting {delay:.1f} seconds before next download...")
                time.sleep(delay)
                return
                
            except requests.exceptions.RequestException as e:
                print(f"Error downloading hymn {hymn_number} (attempt {attempt + 1}/{max_retries}): {e}")
                if attempt < max_retries - 1:
                    # Exponential backoff: wait longer after each failed attempt
                    wait_time = (attempt + 1) * 5 + random.random() * 5
                    print(f"Waiting {wait_time:.1f} seconds before retrying...")
                    time.sleep(wait_time)
                else:
                    missing_hymns.append(hymn_number)

def main():
    output_dir = "Resources/Audio"
    # SDA Hymnal has 695 hymns
    for hymn_number in range(1, 696):
        download_hymn(hymn_number, output_dir)
    
    # Print summary of missing hymns
    if missing_hymns:
        print("\nHymns with no audio available:")
        print(sorted(missing_hymns))
        print(f"\nTotal missing hymns: {len(missing_hymns)}")

if __name__ == "__main__":
    main()
