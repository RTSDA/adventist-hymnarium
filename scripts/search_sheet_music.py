import json
import os
import requests
from urllib.parse import quote
import time
from pathlib import Path

# You'll need to get these from Google Cloud Console
GOOGLE_API_KEY = "YOUR_API_KEY"
SEARCH_ENGINE_ID = "YOUR_SEARCH_ENGINE_ID"

def load_hymns():
    """Load hymns from the 1941 hymnal JSON file."""
    json_path = Path("1941_hymnal.json")
    if not json_path.exists():
        print(f"Error: {json_path} not found")
        return []
    
    with open(json_path, 'r', encoding='utf-8') as f:
        hymns = json.load(f)
    return hymns

def search_sheet_music(hymn_title):
    """Search for sheet music using Google Custom Search API."""
    base_url = "https://www.googleapis.com/customsearch/v1"
    
    # Construct the search query
    query = f"{hymn_title} sheet music hymn score filetype:pdf OR filetype:png OR filetype:jpg"
    encoded_query = quote(query)
    
    params = {
        'key': GOOGLE_API_KEY,
        'cx': SEARCH_ENGINE_ID,
        'q': encoded_query,
        'searchType': 'image',
        'fileType': 'png,jpg,pdf',
        'num': 5  # Number of results to return
    }
    
    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error searching for {hymn_title}: {e}")
        return None

def download_sheet_music(url, save_path):
    """Download sheet music from URL."""
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        with open(save_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        return True
    except requests.exceptions.RequestException as e:
        print(f"Error downloading {url}: {e}")
        return False

def main():
    # Create output directory
    output_dir = Path("1941_sheet_music")
    output_dir.mkdir(exist_ok=True)
    
    # Load hymns
    hymns = load_hymns()
    if not hymns:
        return
    
    print(f"Loaded {len(hymns)} hymns")
    
    # Process each hymn
    for hymn in hymns:
        hymn_number = hymn['number']
        hymn_title = hymn['title']
        
        # Skip if we already have sheet music for this hymn
        hymn_dir = output_dir / f"{hymn_number:03d}"
        if hymn_dir.exists():
            print(f"Skipping hymn {hymn_number} - already processed")
            continue
        
        print(f"Processing hymn {hymn_number}: {hymn_title}")
        
        # Search for sheet music
        results = search_sheet_music(hymn_title)
        if not results or 'items' not in results:
            print(f"No results found for hymn {hymn_number}")
            continue
        
        # Create directory for this hymn
        hymn_dir.mkdir(exist_ok=True)
        
        # Download each result
        for i, item in enumerate(results['items'], 1):
            url = item['link']
            ext = url.split('.')[-1].lower()
            if ext not in ['pdf', 'png', 'jpg', 'jpeg']:
                ext = 'png'  # Default to png
            
            save_path = hymn_dir / f"sheet_{i}.{ext}"
            if download_sheet_music(url, save_path):
                print(f"Downloaded sheet music {i} for hymn {hymn_number}")
        
        # Sleep to avoid hitting API rate limits
        time.sleep(2)

if __name__ == "__main__":
    main()
