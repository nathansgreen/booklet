//
//  main.swift
//  booklet
//
//  Created by Boris Herman on 15/10/2019.
//  Copyright © 2019 Sight&Sound s.p. All rights reserved.
//

import PDFKit

let inFile : String

if CommandLine.arguments.count == 2 {
    inFile = CommandLine.arguments[1]
    if ["-h", "-?", "-help", "--help"].contains(inFile) {
        print("Usage: booklet <inputfile>")
        exit(0)
    }
} else {
    print("Usage: booklet <inputfile>")
    exit(1)
}
let srcUrl = URL(fileURLWithPath: inFile)

guard var srcDoc = PDFDocument(url: srcUrl) else {
    print("Source file \(inFile) cannot be opened, exiting")
    exit(2)
}

let outFile = FileManager().temporaryDirectory.appendingPathComponent("Booklet-\(srcUrl.lastPathComponent)")

let invertAlternatePages = true
let pageCount : Int = srcDoc.pageCount
// let sheets = 12
// let pageCount = sheets * 4
let paddedPageCount : Int = ((pageCount + 3) / 4) * 4 - 1
var pageOrder : [Int] = []
for i in 0...paddedPageCount/4 {
    pageOrder.append(paddedPageCount - i * 2)
    pageOrder.append(i * 2)
    pageOrder.append(i * 2 + 1)
    pageOrder.append(paddedPageCount - 1 - i * 2)
}

var firstBounds = (srcDoc.page(at: 0)?.bounds(for: .mediaBox))!
var box = CGRect(x: 0, y: 0, width: firstBounds.width * 2, height: firstBounds.height)
let infoDict = ["kCGPDFContextCreator" : "booklet" ] as CFDictionary
let ctx = CGContext(outFile as CFURL, mediaBox: &box, infoDict)

for page in stride(from: 0, to: pageOrder.count, by: 2) {
    var (page1, page2) = ( PDFPage(), PDFPage() )
    var (pg1bounds, pg2bounds) = (firstBounds,firstBounds)
    if let pg1 = srcDoc.page(at: pageOrder[page]) {
        page1 = pg1
        pg1bounds = pg1.bounds(for: .mediaBox)
    }
    if let pg2 = srcDoc.page(at: pageOrder[page+1]) {
        page2 = pg2
        pg2bounds = pg2.bounds(for: .mediaBox)
    }
    var pageBox = pg1bounds.union(pg2bounds).applying(CGAffineTransform(scaleX: 2, y: 1))
    ctx?.beginPage(mediaBox: &pageBox)
    if invertAlternatePages && (page + 2) % 4 == 0 {
        ctx?.rotate(by: .pi)  // 180º
        ctx?.translateBy(x: -pageBox.width , y: -pageBox.height)
     }
    if let pageRef = page1.pageRef {
        ctx?.drawPDFPage(pageRef)
    }
    ctx?.translateBy(x: pageBox.width/2, y: 0)
    if let pageRef = page2.pageRef {
        ctx?.drawPDFPage(pageRef)
    }
    ctx?.endPage()
}
ctx?.closePDF()

if !NSWorkspace.shared.open(outFile) {
   print("Destination file \(outFile) cannot be opened, exiting")
   exit(3)
}
