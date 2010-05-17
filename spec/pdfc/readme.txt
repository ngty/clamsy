i-net PDF Comparer v1.01
-------------------------
Copyright i-net software GmbH 2009-2010
All rights reserved

1. Introduction
---------------
The PDF Comparer is a tool specifically for comparing two PDF files (or folders containing PDF files)
for differences.
It is useful for comparing the PDF output of a Crystal Reports report with the PDF output of this same
report as exported by i-net Crystal-Clear, or for comparing the PDF output of two different versions
of i-net Crystal-Clear for any differences or behavioral changes. The following elements are compared
and any differences logged:

 * Text differences (letters or words missing)
 * Line/Arc/Box differences (lines or boxes missing or with different styles)
 * Image differences (images missing)
 * Margin differences (page margins different)

These differences each have a configurable tolerance value so that minor differences can be
ignored if necessary. (See point 3 - Configuration)

2. Parameters
-------------
Usage:
PDFC [-c <config file>] [-[i][o]] [<Folder1> <Folder2> | <File1> <File2>]

  -c       Specify a configuration file (config.xml) for PDFC. If none is specified, the default "config.xml" is taken
  -i       Creates diff images in <Folder1>/differences for any differences found (recommended for a graphical comparison)
  -o       Creates images for each page of each version (need only be used for debug purposes)

Note that if using two folders, the PDF files must have the same names in each folder.

Will result in an output on the console for any differences found between the PDFs being compared.

Example usage:

PDFC -i CRFolder CCFolder

This would compare all PDF files in the folder "CRFolder" with the PDF files of the same name in the folder "CCFolder".

3. Configuration
----------------
The following tolerance values can be set in the config.xml file:

CHART_DENSITY_THRESHOLD 
          (Decimal) density threshold: ((number of shapes)^3 / area size)
CHART_REMOVAL_MARGIN 
          (Decimal) percent of shape height to use as margin for removing PDF elements above and below detected charts
CREATE_DIFFIMAGES 
          True to create png files with the marked difference of the compared pages
CREATE_ORIGIMAGES 
          True to create a png file for each page that is compared
LOG_LEVEL
         Level for Logging (OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE, ALL). The default is set to WARN
MAX_ERRORS_PER_REPORT 
          maximum number of errors that can occur before the comparison is canceled for the current pdf file.
MAX_WORD_DIFFERENCES 
          maximum number of differences that can occur before the comparison is canceled
MODULES 
          comma separated list of modules to be executed for each page
NORMALIZERS 
          comma separated list of normalizers to be executed before and after each page
TOLERANCE_BOX_ROUND_EDGES 
          (Integer) maximum number of pixels that a curve control point may differ in total
TOLERANCE_IMAGE_DISTANCE 
          maximum number of pixels that the position of an image can differ
TOLERANCE_IMAGE_SIZE 
          maximum difference in percent, that the area spanned by an image may differ
TOLERANCE_LINE_POSITION 
          (Decimal) maximum number of pixels that the position of a line or curves can differ per axis
TOLERANCE_LINE_SIZE 
          (Integer) maximum number of pixels that the length of a line can differ in total
TOLERANCE_LINE_STYLE 
          (Boolean) if true, different stroke styles will be an error
TOLERANCE_LINE_THICKNESS 
          (Integer) maximum difference in stroke thickness of two lines or curves
TOLERANCE_PAGE_LEFTCORNER 
          maximum number of pixels that the left or top margin of a page can differ (is the upper left corner of all elements)
TOLERANCE_PAGE_RATIO 
          tolerance for the aspect ratio of the pdf page
TOLERANCE_PAGE_SIZE 
          maximum number of pixels that the width or height of a page can differ
TOLERANCE_UNDERLINE_LENGTH 
          (Decimal) the maximum difference in percent, which the length of underlines may differ

4. Support

If you have any questions or problems, please do not hesitate to contact tools@inetsoftware.de for technical support.
