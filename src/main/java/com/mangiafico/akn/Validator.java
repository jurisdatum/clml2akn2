package com.mangiafico.akn;

import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedList;
import java.util.List;

import javax.xml.XMLConstants;
import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSInput;
import org.w3c.dom.ls.LSResourceResolver;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import net.sf.saxon.dom.NodeOverNodeInfo;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.s9api.XdmNode;

public class Validator {
	
	private static final String schema = "/akoma-ntoso/akomantoso30.xsd";
	private final javax.xml.validation.Validator validator;
	
	public Validator() {
        SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        factory.setResourceResolver(new Resolver());
        InputStream stream = Validator.class.getResourceAsStream(schema);
        Source source = new StreamSource(stream);
        Schema schema;
		try {
			schema = factory.newSchema(source);
		} catch (SAXException e) {
			throw new RuntimeException(e);
		}
		validator = schema.newValidator();
	}

	private static class Resolver implements LSResourceResolver {
		
		private final DOMImplementationLS impl;

		private Resolver() {
			DOMImplementationRegistry registry;
			try {
				registry = DOMImplementationRegistry.newInstance();
			} catch (ClassNotFoundException | InstantiationException | IllegalAccessException | ClassCastException e) {
				throw new RuntimeException(e);
			}
			impl = (DOMImplementationLS) registry.getDOMImplementation("LS");
		}

		@Override
		public LSInput resolveResource(String type, String namespaceURI, String publicId, String systemId, String baseURI) {
			String path = "/akoma-ntoso/";
			InputStream stream = Resolver.class.getResourceAsStream(path + systemId);
			if (stream == null)
				throw new RuntimeException(systemId);
			LSInput input = impl.createLSInput();
			input.setSystemId(systemId);
			input.setBaseURI(baseURI);
			input.setByteStream(stream);
			return input;
		}

	}
	
	public List<SAXException> validate(Source akn) {
		ErrorHandler errorHandler = new ErrorHandler();
		validator.setErrorHandler(errorHandler);
		try {
			validator.validate(akn);
		} catch (SAXException | IOException e) {
			throw new RuntimeException(e);
		}
		return errorHandler.errors;
	}

	public List<SAXException> validate(XdmNode akn) {
		NodeInfo info = akn.getUnderlyingNode();
		NodeOverNodeInfo node = NodeOverNodeInfo.wrap(info);
		Source source = new DOMSource(node);
		return validate(source);
	}

	private static class ErrorHandler implements org.xml.sax.ErrorHandler {
		List<SAXException> errors = new LinkedList<SAXException>();
		public void warning(SAXParseException exception) throws SAXException {
			errors.add(exception);
		}
		public void error(SAXParseException exception) throws SAXException {
			errors.add(exception);
		}
		public void fatalError(SAXParseException exception) throws SAXException {
			errors.add(exception);
		}
	}

}
