import Foundation
import PDFKit

struct HymnSheet: Codable {
    let hymnNumber: Int
    let startPage: Int
    let pageCount: Int
    let sharedPage: Bool  // true if the page contains multiple hymns
    
    // Used when a page contains multiple hymns
    let pageRect: CGRect?
    
    static func loadSheetMusic(pdfURL: URL) -> PDFDocument? {
        return PDFDocument(url: pdfURL)
    }
    
    func getSheetPages(from pdfDocument: PDFDocument) -> [PDFPage]? {
        var pages: [PDFPage] = []
        
        for pageIndex in startPage...(startPage + pageCount - 1) {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            if sharedPage, let rect = pageRect {
                // If this is a shared page, crop to just this hymn's portion
                page.setBounds(rect, for: .cropBox)
            }
            
            pages.append(page)
        }
        
        return pages.isEmpty ? nil : pages
    }
}
