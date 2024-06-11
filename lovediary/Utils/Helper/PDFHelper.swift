//
//  PDFHelper.swift
//  SimpleDiaryForGirl
//
//  Created by daovu on 24/02/2021.
//  Copyright © 2021 Komorebi. All rights reserved.
//

import Foundation
import UIKit

struct PDFHelper {
    
    // A4 size
    private static let pageRect =  CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
    
    private static let marginPoint = CGPoint(x: 20, y: 60)
    
    private static let marginSize = CGSize(width: marginPoint.x * 2, height: marginPoint.y * 2)
    
    static let printableRect = CGRect(x: marginPoint.x, y: marginPoint.y,
                                      width: pageRect.size.width - marginSize.width,
                                      height: pageRect.size.height - marginSize.height)
    
    static func anotherExportPdf(from attributedString: NSAttributedString) -> URL? {
        return FileHelper.writeToFile(data: generatePdfFile(from: attributedString), fileExtension: ".pdf")
    }
    
    static func generatePdfFile(from attributedString: NSAttributedString) -> Data {
        let printFormatter = UISimpleTextPrintFormatter(attributedText: attributedString)
        
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        renderer.setValue(NSValue(cgRect: pageRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        renderer.prepare(forDrawingPages: NSRange(location: 0, length: renderer.numberOfPages))
        
        let bounds = UIGraphicsGetPDFContextBounds()
        
        for i in 0  ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            
            let currentContext = UIGraphicsGetCurrentContext()
            currentContext?.setFillColor(UIColor.white.cgColor)
            currentContext?.fill(pageRect)
            
            renderer.drawPage(at: i, in: bounds)
        }
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
}
