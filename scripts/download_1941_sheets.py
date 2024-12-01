import os
import requests
from bs4 import BeautifulSoup
import time
import re
import fitz  # PyMuPDF
import json

class HymnScraper:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        })
        self.base_url = "https://hymnary.org/hymn/CHSD1941"
        
    def download_sheet_music(self, hymn_number, output_dir):
        url = f"{self.base_url}/{hymn_number}"
        print(f"\nAccessing {url}")
        
        try:
            # Get the hymn page
            response = self.session.get(url)
            response.raise_for_status()
            print("Successfully loaded hymn page")
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # First try to find the "Page Scans" section
            page_scans = soup.find('div', {'id': 'pagescans'})
            if page_scans:
                print("Found Page Scans section")
                links = page_scans.find_all('a', href=True)
            else:
                print("No Page Scans section found, searching whole page")
                links = soup.find_all('a', href=True)
            
            # Look for PDF links and image links
            download_links = []
            for link in links:
                href = link['href']
                if ('pdf' in href.lower() or 'png' in href.lower() or 'jpg' in href.lower()) and \
                   ('page' in href.lower() or 'score' in href.lower()):
                    if not href.startswith('http'):
                        href = f"https://hymnary.org{href}"
                    download_links.append(href)
            
            if not download_links:
                print(f"No sheet music found for hymn {hymn_number}")
                return
            
            print(f"Found {len(download_links)} files to download")
            
            # Download each file found
            for idx, file_url in enumerate(download_links):
                print(f"Downloading file {idx + 1}/{len(download_links)} from {file_url}")
                
                response = self.session.get(file_url)
                response.raise_for_status()
                
                # Determine file extension from URL
                ext = 'pdf' if 'pdf' in file_url.lower() else 'png' if 'png' in file_url.lower() else 'jpg'
                filename = f"hymn_{hymn_number:03d}_{idx + 1}.{ext}"
                filepath = os.path.join(output_dir, filename)
                
                with open(filepath, 'wb') as f:
                    f.write(response.content)
                print(f"Successfully downloaded {filename}")
                
                # Be nice to the server
                time.sleep(1)
                
        except Exception as e:
            print(f"Error downloading hymn {hymn_number}: {str(e)}")

def extract_hymn_pages(pdf_path, output_dir):
    """Extract individual hymn pages from the main PDF."""
    print(f"Opening PDF: {pdf_path}")
    doc = fitz.open(pdf_path)
    hymns = []
    current_hymn = None
    current_pages = []
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    for page_num in range(doc.page_count):
        page = doc[page_num]
        text = page.get_text()
        
        # Look for hymn numbers at the start of lines
        lines = text.split('\n')
        for line in lines:
            # Try to identify hymn numbers (they're usually alone on a line)
            if line.strip().isdigit():
                hymn_num = int(line.strip())
                
                # If we were collecting pages for a previous hymn, save it
                if current_hymn and current_pages:
                    output_pdf = os.path.join(output_dir, f"hymn_{current_hymn['number']:03d}.pdf")
                    new_doc = fitz.open()
                    for p in current_pages:
                        new_doc.insert_pdf(doc, from_page=p, to_page=p)
                    new_doc.save(output_pdf)
                    new_doc.close()
                    print(f"Saved hymn {current_hymn['number']} to {output_pdf}")
                    hymns.append(current_hymn)
                
                # Start collecting pages for the new hymn
                current_hymn = {"number": str(hymn_num)}
                current_pages = [page_num]
                
                # Try to find the title (usually in the next few lines)
                for potential_title in lines[lines.index(line)+1:lines.index(line)+5]:
                    if potential_title.strip() and not potential_title.strip().isdigit():
                        current_hymn["title"] = potential_title.strip()
                        break
            
            # If we're currently collecting a hymn and this page seems to be a continuation
            elif current_hymn is not None:
                if page_num not in current_pages:
                    current_pages.append(page_num)
    
    # Don't forget to save the last hymn
    if current_hymn and current_pages:
        output_pdf = os.path.join(output_dir, f"hymn_{current_hymn['number']:03d}.pdf")
        new_doc = fitz.open()
        for p in current_pages:
            new_doc.insert_pdf(doc, from_page=p, to_page=p)
        new_doc.save(output_pdf)
        new_doc.close()
        print(f"Saved hymn {current_hymn['number']} to {output_pdf}")
        hymns.append(current_hymn)
    
    # Save hymn metadata to JSON
    json_path = os.path.join(output_dir, "hymns.json")
    with open(json_path, 'w') as f:
        json.dump({"hymns": hymns}, f, indent=4)
    print(f"Saved hymn metadata to {json_path}")
    
    doc.close()

def main():
    # Create output directory
    output_dir = "1941_sheet_music"
    os.makedirs(output_dir, exist_ok=True)
    
    scraper = HymnScraper()
    
    # Start with a small range for testing
    start_hymn = 1
    end_hymn = 10  # We'll start with just 10 hymns to test
    
    for hymn_number in range(start_hymn, end_hymn + 1):
        print(f"\nProcessing hymn {hymn_number}/{end_hymn}...")
        scraper.download_sheet_music(hymn_number, output_dir)
        # Add a small delay between hymns
        time.sleep(2)

    pdf_path = "/Users/benjaminslingo/Downloads/1941-sda-hymnal-1.pdf"
    output_dir = "hymn_sheets"
    extract_hymn_pages(pdf_path, output_dir)

if __name__ == "__main__":
    main()
