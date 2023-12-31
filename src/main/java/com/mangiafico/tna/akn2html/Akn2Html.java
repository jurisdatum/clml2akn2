package com.mangiafico.tna.akn2html;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import com.mangiafico.Xml;
import com.mangiafico.akn.Akn;
import com.mangiafico.tna.clml2akn.Helper;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

public class Akn2Html {
	
	public enum Option { showAnnotations, showExtent, showProspective }

	private final XsltExecutable stylesheet;

	public Akn2Html() throws IOException {
		XsltCompiler compiler = Xml.processor.newXsltCompiler();
		InputStream file = Akn2Html.class.getResourceAsStream("/transform/akn2html.xsl");
		Source source = new StreamSource(file);
		try {
			stylesheet = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			file.close();
		}
	}

//	public void transform(Akn akn, String cssPath, EnumSet<Option> options) {
//		XsltTransformer transform = stylesheet.load();
//		transform.setSource(akn.root.asSource());
//		transform.setParameter(new QName("show-annotations"), new XdmAtomicValue(options.contains(Option.showAnnotations)));
//		transform.setParameter(new QName("show-extent"), new XdmAtomicValue(options.contains(Option.showExtent)));
//		transform.setParameter(new QName("show-prospective"), new XdmAtomicValue(options.contains(Option.showProspective)));
//		XdmDestination html = new XdmDestination();
//		transform.setDestination(html);
//	    try {
//			transform.transform();
//		} catch (SaxonApiException e) {
//			throw new RuntimeException("error performing transform", e);
//		}
//	    return html.getXdmNode();
//	}
	
	public void transform(XdmNode akn, String cssPath, OutputStream out) {
		XsltTransformer transform = stylesheet.load();
		if (cssPath != null)
			transform.setParameter(new QName("css-path"), new XdmAtomicValue(cssPath));
		try {
			transform.setSource(akn.asSource());
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
//		Serializer html = Xml.processor.newSerializer(out); 
//		transform.setDestination(html);
		transform.setDestination(Helper.makeDestination(new StreamResult(out), Helper.html5properties));
		try {
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
	}

	public void transform(Akn akn, String cssPath, OutputStream out) {
		transform(akn.root, cssPath, out);
	}
	
	public String transform(XdmNode akn, String cssPath) throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		transform(akn, cssPath, baos);
		return baos.toString("UTF-8");
	}
	public String transform(Akn akn, String cssPath) throws IOException {
		return transform(akn.root, cssPath);
	}

}
