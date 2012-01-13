#!/bin/env dls-python2.6

import sys
from PyQt4.QtCore import QUrl
from PyQt4.QtGui import QApplication, QPrinter
from PyQt4.QtWebKit import QWebView

app = QApplication(sys.argv)
view = QWebView()
view.load(QUrl(sys.argv[1]))

def printPage(ok):
    printer = QPrinter()
    printer.setOutputFormat(QPrinter.PdfFormat)
    printer.setOrientation(QPrinter.Landscape)
    printer.setPageMargins(0.1,0.1,0.1,0.1, QPrinter.Millimeter)
    printer.setOutputFileName(sys.argv[2])
    view.print_(printer)    
    app.exit()

if len(sys.argv) > 2:
    view.loadFinished.connect(printPage)
else:
    view.showFullScreen()    
app.exec_()
