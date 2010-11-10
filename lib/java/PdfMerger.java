import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

import com.itextpdf.text.Document;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfImportedPage;
import com.itextpdf.text.pdf.PdfReader;
import com.itextpdf.text.pdf.PdfWriter;

// NOTE: Adapted from
// http://viralpatel.net/blogs/2009/06/itext-tutorial-merge-split-pdf-files-using-itext-jar.html
public class PdfMerger {

  public static void main(String[] args) {
    concat(args[0], args[1]);
  }

  public static void concat(String srcFilesStr, String outFile) {
    FileOutputStream outStream = getOutStream(outFile);
    Iterator<String> iterator = Arrays.asList(srcFilesStr.split(",")).iterator();

    Document document = null;
    PdfWriter writer = null;
    PdfContentByte cb = null;

    try {
      while (iterator.hasNext()) {
        PdfReader reader = new PdfReader(getInputStream(iterator.next()));
        int currentPage = 1;
        int totalPages = reader.getNumberOfPages();

        if(document == null) {
          document = new Document(reader.getPageSizeWithRotation(1));
          writer = PdfWriter.getInstance(document, outStream);
          document.open();
          cb = writer.getDirectContent();
        }

        for(; currentPage<=totalPages; currentPage++) {
          document.newPage();
          cb.addTemplate(writer.getImportedPage(reader, currentPage), 0, 0);
        }
      }

      outStream.flush();
      document.close();
      outStream.close();

    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (document.isOpen())
        document.close();
      try {
        if (outStream != null)
          outStream.close();
      } catch (IOException ioe) {
        ioe.printStackTrace();
      }
    }
  }

  private static FileInputStream getInputStream(String file) {
    FileInputStream stream = null;
    try {
      stream = new FileInputStream(file);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return stream;
  }

  private static FileOutputStream getOutStream(String file) {
    FileOutputStream stream = null;
    try {
      stream = new FileOutputStream(file);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return stream;
  }

}
