#!/bin/bash
##################################################
# This shell script takes a (multipage) TIF file #
# as parameter and converts it to a PDF with     #
# embedded text.                                 #
#                                                #
# External tools needed are;                     #
# convert from the imagemagick package           #
# (sudo apt-get imagemagick imagemagick-common)  #
# pdftk (sudo apt-get pdftk)                     #
# tesseract and tesseract language files         #
# (sudo apt-get tesseract-ocr libtesseract3      #
#  tesseract-ocr-deu tesseract-ocr-eng)          # 
# pdfsandwich (download from                     #
# http://www.tobias-elze.de/pdfsandwich/         #
#                                                #
# In the below script replace AName and CName    #
# with your name for the PDFs metadata.          #
#                                                #
# To optimize the OCR adjust the following       #
# pdfsandwich parameters:                        #
# -nthreads = number of your processor cores     #
# -lang deu|eng = language of your source file   #
# -rgb = create coloured PDFs                    # 
##################################################
if [ "$#" != "1" -o "$1" == "--help" ]
then
  echo "Usage: tif2pdf.sh file.tif"
  echo "Usage: tif2pdf.sh --help to get this help."
  echo "This converts the given file.tif into a PDF" 
  echo "with embedded text. The PDF is than searchable"
  echo "and the text can be extracted with pdftotext."
fi
filename=`basename "$1" .tif`
echo "converting ${filename}.tif to ${filename}.pdf"
if [ -f "${filename}".tif ]
then
  echo "  convert tif to pdf"
  convert "${filename}".tif foo.pdf
  echo "RETVAL=$?"
  echo "  doing OCR and embedding text to pdf"
  pdfsandwich -nthreads 2 -rgb -lang deu -o bar.pdf foo.pdf
  echo "RETVAL=$?"
  echo "  adding metadata"
  date=`echo ${filename} | cut -d ' ' -f 1`
  (echo InfoKey: Author; echo InfoValue: AName; echo InfoKey: Company; echo InfoValue: Privat; echo InfoKey: CreationDate; echo InfoValue: $date; echo InfoKey: Creator; echo InfoValue: CName; echo InfoKey: Title; echo InfoValue: ${filename}; echo InfoKey: Subject; echo InfoValue: ${filename}; echo InfoKey: Keywords; echo InfoValue: ${filename}) > foo.meta
  pdftk bar.pdf update_info foo.meta output "${filename}".pdf
  echo "RETVAL=$?"
  rm foo.pdf foo.meta bar.pdf
else
  echo "file $1 not found" 
fi
