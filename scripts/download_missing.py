import os
import requests
from tqdm import tqdm
import time
import random

# List of missing hymns
MISSING_HYMNS = [7, 37, 95, 138, 148, 230, 391, 405, 424, 425, 450, 551, 582, 599, 622, 630, 634, 653, 661, 671]

def download_hymn(hymn_number, output_dir):
    hymn_number_str = str(hymn_number).zfill(3)
    output_path = os.path.join(output_dir, f"{hymn_number_str}.mp3")
    
    if os.path.exists(output_path):
        print(f"Hymn {hymn_number} already exists, skipping...")
        return True, None

    urls = [
        f"https://s3.us-east-2.wasabisys.com/hymnalstorage/english/1985%20version/instrumental/{hymn_number_str}.mp3",
        f"https://s3.us-east-2.wasabisys.com/hymnalstorage/english/1941%20version/instrumental/{hymn_number_str}.mp3"
    ]

    for url in urls:
        try:
            print(f"Trying URL: {url}")
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            response = requests.get(url, headers=headers, stream=True)
            response.raise_for_status()
            
            # Get total file size for progress bar
            total_size = int(response.headers.get('content-length', 0))
            
            if total_size < 50000:  # If file is too small (likely an error page)
                print(f"File too small, likely not a valid audio file")
                continue
            
            # Save the file with progress bar
            with tqdm(total=total_size, unit='iB', unit_scale=True) as pbar:
                with open(output_path, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        if chunk:
                            size = f.write(chunk)
                            pbar.update(size)
            
            print(f"Successfully downloaded hymn {hymn_number}")
            return True, None
            
        except requests.exceptions.RequestException as e:
            print(f"Failed with error: {e}")
            continue
    
    return False, f"Failed to download hymn {hymn_number} from both 1985 and 1941 versions"

def main():
    # Create output directory if it doesn't exist
    output_dir = os.path.join("Resources", "Audio")
    os.makedirs(output_dir, exist_ok=True)
    
    still_missing = []
    
    for hymn_number in MISSING_HYMNS:
        print(f"\nAttempting to download hymn {hymn_number}...")
        success, error = download_hymn(hymn_number, output_dir)
        
        if not success:
            print(error)
            still_missing.append(hymn_number)
        
        # Add a delay between downloads
        if hymn_number != MISSING_HYMNS[-1]:  # Don't delay after the last hymn
            delay = 1 + random.random() * 2
            print(f"Waiting {delay:.1f} seconds before next download...")
            time.sleep(delay)
    
    if still_missing:
        print("\nThe following hymns are still missing:")
        print(still_missing)
    else:
        print("\nAll missing hymns were successfully downloaded!")

if __name__ == "__main__":
    main()
