import java.io.*;
import java.util.*;



/** convert bibles as provided by http://unbound.biola.edu/ to CES-style XML */
public class WorldBible2CES {

	private enum Field {
		orig_book_index, orig_chapter, orig_verse, text, orig_subverse
	}
	
	/** argument file contains a mapping to CES ids<br/>
		read WN Bible CSV file from stdin, write CES-style XML to stdout */
	public static void main(String[] argv) throws Exception {

		// prepare id table
		// 1st col CES id
		// 2nd col WN id
		Hashtable<String,String> idmapping = new Hashtable<String,String>(); 
		BufferedReader in = new BufferedReader(new FileReader(argv[0]));
		for(String line = in.readLine(); line !=null; line=in.readLine()) {
			line=line.replaceFirst("#.*", "").trim();
			String[] fields =line.split("\t");
			if(fields.length>1) 
				idmapping.put(fields[1],fields[0]);
		}
		in.close();
		
		WorldBible2CES converter = new WorldBible2CES(idmapping);
		
		converter.processWNtab(new InputStreamReader(System.in), new OutputStreamWriter(System.out));
	}
	
	private final Map<String,String> origid2cesid;
	
	public WorldBible2CES(Map<String,String> origid2cesid) {
		this.origid2cesid = origid2cesid;
	}
	
	protected void processWNtab(Reader input, Writer output) throws IOException {

		// read header
		String source = "";
		String copyright = "";
		String language = "";
		String note = "";
		String columns = "";
		String name="";
		Date date = new Date();
		
		BufferedReader in = new BufferedReader(input);
		Writer out = output;
		String line;
		for(line=in.readLine(); line!=null && line.startsWith("#"); line=in.readLine()) {
			if(source==null)
				source=line.replaceFirst("#","").trim();
			else if(line.startsWith("#copyright")) 
				copyright=line.replaceFirst("#copyright","").trim();
			else if(line.startsWith("#language"))
				language=line.replaceFirst("#language","").trim();
			else if(line.startsWith("#name"))
				name=line.replaceFirst("#name","").trim();
			else if(line.startsWith("#note"))
				note=line.replaceFirst("#note","").trim();
			else if(line.startsWith("#columns"))
				columns=line.replaceFirst("#columns","").trim();
		}

		Hashtable<Field,Integer> field2pos = new Hashtable<Field,Integer>();
		String[] fields = columns.split("\t");
		for(int i = 0; i<fields.length; i++) {
			try {
				Field f = Field.valueOf(fields[i]);
				field2pos.put(f, i);
			} catch (Exception e) {}
		}
		
		// write header
		out.write("<?xml version=\"1.0\" encoding=\"utf-8\"?><!DOCTYPE cesDoc SYSTEM \"cesDoc.dtd\">\n");
		out.write("<cesDoc version=\"4.3\" type=\"bible\" TEIform=\"modif-TEI.corpus 2\">\n");
		out.write("<cesHeader version=\"4.1\" type=\"text\" creator=\""+this.getClass().getSimpleName()+"\" status=\"new\" " +
				"date.created=\""+date+"\" TEIform=\"modif-TEI.corpus 2\"");
		if(!language.equals("")) out.write(" lang=\""+language+"\"");
		out.write(">\n");
		out.write("<fileDesc>\n" +
					"<titleStmt>\n" +
						"<h.title>"+name+"</h.title>\n" +
						"<respStmt>\n" +
							"<respName>"+this.getClass().getSimpleName()+"</respName>\n" +
							"<respType>converted from tab format to CES-style XML</respType>\n" +
						"</respStmt>\n" +
					"</titleStmt>\n" +
					"<editionStmt version=\"1.0\">initial release</editionStmt>\n" +
					"<publicationStmt>\n" +
						"<distributor>Christian Chiarcos</distributor>\n" +
						"<pubAddress>ISI/USC</pubAddress>\n" +
						"<availability status=\"restricted\"> <!-- to be clarified -->\n"+
							"Until the copyright is clarified, currently available for restricted use only.\n"+
							"If you are interested to use it, please contact Christian Chiarcos, chiarcos@isi.edu"+
						"</availability>\n" +
						"<pubDate value=\""+date+"\">"+date+"</pubDate>\n"+
					"</publicationStmt>\n"+
					"<sourceDesc>\n"+
						"<biblStruct>\n"+
							"<monogr>\n"+
								"<h.title>"+name+"</h.title>\n"+
								"<imprint>\n"+
									"<pubDate>Unknown</pubDate>\n"+
									"<publisher>"+source+"</publisher>"+
								"</imprint>\n"+
							"</monogr>\n"+
						"</biblStruct>\n"+
					"</sourceDesc>\n"+
				"</fileDesc>\n");
		out.write("<encodingDesc>\n"+
				"<projectDesc>\n"+
"retrieved from http://unbound.biola.edu:\n"+
"This Website is Copyright (c) 2005-2006 Biola University.\n"+
"Biola does not hold the Copyright to any Biblical texts on this site.\n"+
"Some Biblical texts on this site are in the Public Domain,\n"+
"and others are Copyrighted by their Copyright holders.\n\n"+
"This version is encoded in XML, conformant to the SGML specifications\n"+
"of Philipp Resnik's parallel bibles (http://www.umiacs.umd.edu/~resnik/parallel/bible.html),\n"+
"an adaption of the level 1 specifications of the\n"+
"Corpus Encoding Standard, for non-commercial research use.\n"+
"(XML conversion required minor adjustments of the DTD.)\n\n" +
"NOTE: CES is superseded by the TEI, the encoding was chosen for compatibility with Resnik's bibles."+
			"</projectDesc>\n"+
			"<editorialDecl>\n"+
				"<conformance level=\"1\">Corpus Encoding Standard, Version 2.0</conformance>\n"+
				"<correction status=\"unknown\" method=\"silent\"/>\n"+
				"<segmentation>Marked up to the level of chapter and verse.</segmentation>\n"+
			"</editorialDecl>\n"+
		"</encodingDesc>\n");
out.write("<profileDesc>\n"+
	"<langUsage>\n"+
		"<language id=\""+language+"\" iso639=\"TOCHECK\">"+language+"</language>\n"+
	"</langUsage>\n"+
	"<wsdUsage>\n"+
		"<writingSystem id=\"ISO8859-1\">ISO Latin-1 character set for Western European languages (TO BE CHECKED !)</writingSystem>\n"+
	"</wsdUsage>\n"+
	"</profileDesc>\n"+
"</cesHeader>\n");
	out.flush();

		// write data
		out.write("<text>\n" +
				"<body lang=\""+language+"\" id=\""+name.replaceAll("[^a-zA-Z0-9]", " ").trim().replaceAll("  *","_")+"\">\n");

		String lastBook="";
		String lastChapter ="";
		while(line!=null) {
			fields = line.split("\t");
			if(!line.trim().equals(""))
			try {
				String book = fields[field2pos.get(Field.orig_book_index)];
				String chapter = fields[field2pos.get(Field.orig_chapter)];
				String verse = fields[field2pos.get(Field.orig_verse)];
				String subverse = "";
				if(field2pos.get(Field.orig_subverse)!=null) 
					subverse=fields[field2pos.get(Field.orig_subverse)];
				String text = "";
				try {
					text = fields[field2pos.get(Field.text)];
				} catch (ArrayIndexOutOfBoundsException e) {
					// sometimes, verses are omitted, but appear in the index, therefore no exception if only the text is missing
				}
				
				if(!text.equals("")) {
					if(this.origid2cesid.get(book)==null)
						System.err.println("warning: unknow book id \""+book+"\"");
					else 
						book = this.origid2cesid.get(book);
					chapter = book+"."+chapter;
					verse = chapter+"."+verse;
					if(!subverse.equals("")) verse=verse+"."+subverse;
					
					if(!book.equals(lastBook)) {
						if(!lastBook.equals("")) out.write("</div>\n</div>\n");
						out.write("<div id=\""+book+"\" type=\"book\">\n");
						out.write("<div id=\""+chapter+"\" type=\"chapter\">\n");
						lastBook=book;
						lastChapter=chapter;
					} else if(!chapter.equals(lastChapter)) {
						out.write("</div>\n");
						out.write("<div id=\""+chapter+"\" type=\"chapter\">\n");
						lastChapter=chapter;
					}
					out.write("<seg id=\""+verse+"\" type=\"verse\">"+text.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;")+"</seg>\n");
					out.flush();
				}
			} catch (Exception e) {
				System.err.println("Error while reading line \""+line+"\"");
				e.printStackTrace();
			}
			line=in.readLine();
		}

		out.write("</div>\n</div>\n" +
				"</body>\n" +
				"</text>\n"+
				"</cesDoc>");
		out.flush();
	}
}
