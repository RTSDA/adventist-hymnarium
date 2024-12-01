import Foundation
import PDFKit

class PDFService {
    static let shared = PDFService()
    private var pdfDocument: PDFDocument?
    private var hymnSheets: [Int: HymnSheet] = [:]
    
    private init() {
        loadPDFDocument()
        loadHymnSheetData()
    }
    
    private func loadPDFDocument() {
        guard let pdfURL = Bundle.main.url(forResource: "1985-sda-hymnal", withExtension: "pdf") else {
            print("Error: Could not find 1985 hymnal PDF in bundle")
            return
        }
        
        pdfDocument = PDFDocument(url: pdfURL)
    }
    
    private func loadHymnSheetData() {
        // This would ideally come from a JSON file, but for now we'll hardcode a few examples
        // Format: [hymnNumber: (startPage, pageCount, sharedPage, pageRect)]
        let hymnData: [(Int, Int, Int, Bool, CGRect?)] = [
            (1, 33, 1, false, nil),  // Hymn 1 starts on page 33, 1 page, not shared
            (2, 34, 1, false, nil),  // Hymn 2 starts on page 34, 1 page, not shared
            (3, 35, 2, false, nil),  // Hymn 3 starts on page 35, 2 pages, not shared
            // Add more hymns here...
        ]
        
        for (number, start, count, shared, rect) in hymnData {
            hymnSheets[number] = HymnSheet(
                hymnNumber: number,
                startPage: start,
                pageCount: count,
                sharedPage: shared,
                pageRect: rect
            )
        }
    }
    
    func getSheetMusic(for hymnNumber: Int) -> [PDFPage]? {
        guard let pdfDocument = pdfDocument,
              let hymnSheet = hymnSheets[hymnNumber] else {
            return nil
        }
        
        return hymnSheet.getSheetPages(from: pdfDocument)
    }
    
    func preloadHymnal() {
        loadPDFDocument()
    }
}
