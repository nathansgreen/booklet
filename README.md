# booklet
PDF booklet tool for macOS
==========================

Simple command line tool written in Swift that takes a (multi-page) PDF file as its primary argument then creates a PDF booklet, ready to print to a double-sided printer.

In the Release folder you can find Installer package with the Finder Quick Action (Automator workflow) and embedded binary as well as a sample multipage PDF document with the expected output of the tool.

In order to use the Swift command line utilities on older macOS operating systems you need to download from Apple and install the Swift 5 Runtime Support for Command Line Tools from Apple at https://support.apple.com/kb/DL1998

## usage

In a terminal, run  <code>swift [booklet/main.swift](booklet/main.swift)</code> to see simple help instructions.
Additional options can be discovered by looking through the code.

One significant group of arguments relate to taking a subset of pages from a PDF to make the booklet.
This greatly simplifies cases where a single document needs to be broken into smaller booklets.

Another important option is `--invert`, which writes alternate pages upside down.
Some printers do not provide adequate control over double-sided prints, so this option is a great workaround for such tricky situations.


## details

Creating and printing PDFs can be non–intuitive for non-specialists, so I'm including some notes in this section to explain a few bits in case anyone might find it useful.

PDF page rotation / orientation is not helpful for all printing situations.
Despite altering how a PDF appears on screen, the printed output is frequently unaffected.
By rotating pages 180º and adjusting the X/Y coordinates where they are drawn, the new PDF file relies on properly orienting page content rather than setting a page rotation value.
The coordinate adjustment is necessary because rotation alters point at which drawing starts.
