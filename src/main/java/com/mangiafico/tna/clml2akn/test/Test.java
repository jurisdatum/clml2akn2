package com.mangiafico.tna.clml2akn.test;

import java.io.InputStream;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.yaml.snakeyaml.Yaml;

import com.mangiafico.akn.Akn;
import com.mangiafico.tna.Clml;
import com.mangiafico.tna.clml2akn.test.Counter.AlreadyCountedException;

import net.sf.saxon.s9api.SaxonApiException;

public class Test {
	
	private static final String mappingPath = "/test.yaml";
	
	private final Map<List<String>, List<String>> mapping;
	private final List<String> clmlToIgnore;
	private final List<String> aknToIgnore;
	
	private final Set<String> clmlAttributes = new HashSet<String>();
	private final Set<String> aknAttributes = new HashSet<String>();

	@SuppressWarnings("unchecked")
	public Test() {
		InputStream mappingStream = Test.class.getResourceAsStream(mappingPath);
		Iterator<Object> yamlDocs = new Yaml().loadAll(mappingStream).iterator();
		mapping = (Map<List<String>, List<String>>) yamlDocs.next();
		clmlToIgnore = (List<String>) yamlDocs.next();
		aknToIgnore = (List<String>) yamlDocs.next();
		for (Map.Entry<List<String>, List<String>> entry : mapping.entrySet()) {
			for (String clmlXpath : entry.getKey()) {
				if (clmlXpath.contains("/@")) clmlAttributes.add(clmlXpath.substring(clmlXpath.indexOf("/@") + 2));
			}
			for (String aknXpath : entry.getValue()) {
				if (aknXpath.contains("/@")) aknAttributes.add(aknXpath.substring(aknXpath.indexOf("/@") + 2));
			}
		}
	}
		
	public TestResults test(Clml clml, Akn akn) throws AlreadyCountedException, SaxonApiException {
		List<TestResults.ElementMapping> pairings = new LinkedList<TestResults.ElementMapping>();
		Counter clmlCounter = new Counter(clml, clmlAttributes);
//		AkomaNtoso.Counter aknCounter = new AkomaNtoso.Counter(akn, aknAttributes);
		Counter aknCounter = new Counter(akn, aknAttributes);
		for (Entry<List<String>, List<String>> pathLists : mapping.entrySet()) {
			List<String> clmlPaths = pathLists.getKey();
			List<String> aknPaths = pathLists.getValue();
			TestResults.ElementCount clmlCount = new TestResults.ElementCount(clmlPaths, clmlCounter.count(clmlPaths));
			TestResults.ElementCount aknCount = new TestResults.ElementCount(aknPaths, aknCounter.count(aknPaths));
			TestResults.ElementMapping pairing = new TestResults.ElementMapping(clmlCount, aknCount);
			pairings.add(pairing);
		}
		for (String ignore : clmlToIgnore) clmlCounter.count(ignore);
		for (String ignore : aknToIgnore) aknCounter.count(ignore);
		for (final Entry<String, Integer> entry : clmlCounter.getUncountedCounts().entrySet()) {
			String element = entry.getKey();
			Integer count = entry.getValue();
			TestResults.ElementCount clmlCount = new TestResults.ElementCount(element, count);
			TestResults.ElementMapping pairing = new TestResults.ElementMapping(clmlCount, null);
			pairings.add(pairing);
		}
		for (Entry<String, Integer> entry : aknCounter.getUncountedCounts().entrySet()) {
			String element = entry.getKey();
			Integer count = entry.getValue();
			TestResults.ElementCount aknCount = new TestResults.ElementCount(element, count);
			TestResults.ElementMapping pairing = new TestResults.ElementMapping(null, aknCount);
			pairings.add(pairing);
		}
		return new TestResults(pairings);
	}
	
//	public Map<String, Set<XdmNode>> getClmlUncounted(String clml) {
//		Source source = new StreamSource(new StringReader(clml));
//		Counter counter = new Counter(source, CLML.namespaces, clmlAttributes);
//		for (List<String> paths : mapping.keySet())
//			counter.count(paths);
//		counter.count(clmlToIgnore);
//		return counter.getUncounted();
//	}
//	public Map<String, Set<XdmNode>> getAknUncounted(String akn) {
//		Source source = new StreamSource(new StringReader(akn));
//		Counter counter = new Counter(source, AkomaNtoso.namespaces, aknAttributes);
//		for (List<String> paths : mapping.values())
//			counter.count(paths);
//		counter.count(aknToIgnore);
//		return counter.getUncounted();
//	}

}
