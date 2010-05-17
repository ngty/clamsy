#!/bin/bash
DIR=`dirname $0`
java -cp ${DIR}/CCLib.jar:${DIR}/log4j-1.2.15.jar:${DIR}/PDFC.jar:${DIR}/PDFParser.jar com.inet.pdfc.PDFC $@
