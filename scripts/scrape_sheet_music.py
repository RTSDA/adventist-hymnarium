import json
import os
import requests
import time
from pathlib import Path
from bs4 import BeautifulSoup
import re
from urllib.parse import urljoin, quote_plus
import concurrent.futures

class SheetMusicScraper:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        })
        
    def search_hymnary_org(self, hymn_title):
        """Search hymnary.org for sheet music."""
        base_url = "https://hymnary.org"
        search_url = f"{base_url}/search?qu={quote_plus(hymn_title)}"
        
        try:
            response = self.session.get(search_url)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find sheet music links
            results = []
            for link in soup.find_all('a', href=True):
                if 'page/' in link['href'] and ('pdf' in link['href'].lower() or 'score' in link['href'].lower()):
                    results.append(urljoin(base_url, link['href']))
            
            return results[:5]  # Limit to first 5 results
        except Exception as e:
            print(f"Error searching hymnary.org for {hymn_title}: {e}")
            return []

    def search_imslp(self, hymn_title):
        """Search IMSLP for sheet music."""
        search_url = f"https://imslp.org/wiki/Special:Search?search={quote_plus(hymn_title)}+hymn"
        
        try:
            response = self.session.get(search_url)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')
            
            results = []
            for link in soup.find_all('a', href=True):
                if '/wiki/' in link['href'] and not 'Special:' in link['href']:
                    results.append(urljoin('https://imslp.org', link['href']))
            
            return results[:5]
        except Exception as e:
            print(f"Error searching IMSLP for {hymn_title}: {e}")
            return []

    def search_mutopiaproject(self, hymn_title):
        """Search Mutopia Project for sheet music."""
        search_url = f"https://www.mutopiaproject.org/cgibin/make-table.cgi?searchingfor={quote_plus(hymn_title)}"
        
        try:
            response = self.session.get(search_url)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')
            
            results = []
            for link in soup.find_all('a', href=True):
                if '.pdf' in link['href'].lower():
                    results.append(urljoin('https://www.mutopiaproject.org', link['href']))
            
            return results[:5]
        except Exception as e:
            print(f"Error searching Mutopia Project for {hymn_title}: {e}")
            return []

    def download_file(self, url, save_path):
        """Download a file from URL."""
        try:
            response = self.session.get(url, stream=True)
            response.raise_for_status()
            
            with open(save_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            return True
        except Exception as e:
            print(f"Error downloading {url}: {e}")
            return False

def load_hymns():
    """Load hymns from the 1941 hymnal JSON file."""
    json_path = Path("1941_hymnal.json")
    if not json_path.exists():
        print(f"Error: {json_path} not found")
        return []
    
    with open(json_path, 'r', encoding='utf-8') as f:
        hymns = json.load(f)
    return hymns

def process_hymn(scraper, hymn, output_dir):
    """Process a single hymn."""
    hymn_number = hymn['number']
    hymn_title = hymn['title']
    
    # Skip if we already have sheet music for this hymn
    hymn_dir = output_dir / f"{hymn_number:03d}"
    if hymn_dir.exists():
        print(f"Skipping hymn {hymn_number} - already processed")
        return
    
    print(f"Processing hymn {hymn_number}: {hymn_title}")
    
    # Search different sources
    results = []
    results.extend(scraper.search_hymnary_org(hymn_title))
    time.sleep(1)
    results.extend(scraper.search_imslp(hymn_title))
    time.sleep(1)
    results.extend(scraper.search_mutopiaproject(hymn_title))
    
    if not results:
        print(f"No results found for hymn {hymn_number}")
        return
    
    # Create directory for this hymn
    hymn_dir.mkdir(exist_ok=True)
    
    # Download each result
    for i, url in enumerate(results, 1):
        ext = url.split('.')[-1].lower()
        if ext not in ['pdf', 'png', 'jpg', 'jpeg']:
            ext = 'pdf'  # Default to pdf
        
        save_path = hymn_dir / f"sheet_{i}.{ext}"
        if scraper.download_file(url, save_path):
            print(f"Downloaded sheet music {i} for hymn {hymn_number}")
        
        time.sleep(1)  # Be nice to the servers

def main():
    # Create output directory
    output_dir = Path("1941_sheet_music")
    output_dir.mkdir(exist_ok=True)
    
    # Load hymns
    hymns = load_hymns()
    if not hymns:
        return
    
    print(f"Loaded {len(hymns)} hymns")
    
    # Initialize scraper
    scraper = SheetMusicScraper()
    
    # Process hymns with a thread pool
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
        futures = [
            executor.submit(process_hymn, scraper, hymn, output_dir)
            for hymn in hymns
        ]
        concurrent.futures.wait(futures)

if __name__ == "__main__":
    main()
