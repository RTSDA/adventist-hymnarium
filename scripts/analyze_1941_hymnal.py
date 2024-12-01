import fitz  # PyMuPDF
import json
import re

def clean_title(text):
    # Remove common OCR artifacts and normalize spaces
    text = re.sub(r'[^\w\s\-\',.?!]', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def analyze_hymnal_pdf(pdf_path):
    hymn_data = {}
    doc = fitz.open(pdf_path)
    
    # Focus specifically on hymn 688
    target_hymn = "688"
    print(f"\nPerforming detailed search for hymn {target_hymn}...")
    
    # Search through a wider range of pages
    for page_num in range(500, 600):  # Extended range
        if page_num >= doc.page_count:
            break
            
        page = doc[page_num]
        text = page.get_text()
        
        # Split into lines and clean them
        lines = [line.strip() for line in text.split('\n') if line.strip()]
        
        # Look for the hymn number and surrounding context
        for i, line in enumerate(lines):
            if target_hymn in line:
                print(f"\nFound reference on page {page_num + 1}:")
                
                # Print more context (30 lines before and after)
                start_idx = max(0, i-30)
                end_idx = min(len(lines), i+30)
                
                print("\nExtended context (60 lines around match):")
                for j in range(start_idx, end_idx):
                    prefix = ">>> " if j == i else "    "
                    print(f"{prefix}{lines[j]}")
                
                # Look for section headers and titles
                print("\nPotential section headers and titles from this page:")
                for line in lines:
                    if len(line) > 5 and any(c.isalpha() for c in line):
                        if (line.isupper() or 
                            not any(c.isdigit() for c in line) or 
                            any(word in line.upper() for word in ["HYMN", "PSALM", "SECTION", "PART"])):
                            print(f"  {line}")
    
    doc.close()
    return hymn_data

def save_hymn_data(hymn_data, output_path):
    # Sort hymns by number
    sorted_hymns = sorted(hymn_data.values(), key=lambda x: x["number"])
    
    # Calculate some statistics
    total_hymns = len(sorted_hymns)
    hymns_with_shared_pages = sum(1 for hymn in sorted_hymns if hymn["position"]["total"] > 1)
    
    # Find missing hymn numbers
    all_hymn_numbers = set(range(1, 704))  # 1-703
    found_hymn_numbers = set(hymn["number"] for hymn in sorted_hymns)
    missing_hymn_numbers = sorted(all_hymn_numbers - found_hymn_numbers)
    
    print(f"\nStatistics:")
    print(f"Total hymns found: {total_hymns}")
    print(f"Hymns sharing pages with others: {hymns_with_shared_pages}")
    print(f"Missing hymn numbers: {missing_hymn_numbers}")
    
    # Save data with statistics
    with open(output_path, 'w') as f:
        json.dump({
            "hymns": sorted_hymns,
            "statistics": {
                "total_hymns": total_hymns,
                "hymns_with_shared_pages": hymns_with_shared_pages,
                "missing_hymn_numbers": missing_hymn_numbers
            }
        }, f, indent=2)

if __name__ == "__main__":
    pdf_path = "/Users/benjaminslingo/Downloads/1941-sda-hymnal-1.pdf"
    
    print("Performing detailed search for hymn 688...")
    analyze_hymnal_pdf(pdf_path)
