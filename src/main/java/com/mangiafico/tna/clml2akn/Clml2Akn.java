package com.mangiafico.tna.clml2akn;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import com.mangiafico.Xml;
import com.mangiafico.akn.Akn;
import com.mangiafico.tna.Clml;

import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

public class Clml2Akn implements URIResolver {
	
	private static final String stylesheet = "/transform/clml2akn-main.xsl";
	private final XsltExecutable executable;
	
	public Source resolve(String href, String base) throws TransformerException {
		InputStream file = this.getClass().getResourceAsStream("/transform/" + href);
		return new StreamSource(file);
	}
	
	public Clml2Akn(Configuration config) throws IOException {
		XsltCompiler compiler = new Processor(config).newXsltCompiler();
		compiler.setURIResolver(this);
		InputStream file = Clml2Akn.class.getResourceAsStream(stylesheet);
		try {
			executable = compiler.compile(new StreamSource(file));
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			file.close();
		}
	}

	public Clml2Akn() throws IOException {
		this(Xml.processor.getUnderlyingConfiguration());
	}
	
	public XdmNode transform(XdmNode clml) {
		XsltTransformer transform = executable.load();
		transform.setInitialContextNode(clml);
		XdmDestination akn = new XdmDestination();
		transform.setDestination(akn);
		try {
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
		return akn.getXdmNode();
	}

	public Akn transform(Clml clml) {
		XdmNode akn = transform(clml.root);
		return new Akn(akn);
	}

}
