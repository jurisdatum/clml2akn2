package com.mangiafico.tna.clml2akn.test;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.mangiafico.Xml;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmItem;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmValue;

public class Counter {
	
	private final Xml xml;
	private final Set<XdmNode> uncounted = new HashSet<XdmNode>();

	public Counter(Xml xml, Set<String> attributes) {
		this.xml = xml;
		addAll(xml.root, attributes);
	}
	
	private void addAll(XdmNode root, Set<String> attributes) {
		Iterator<XdmItem> attrs = root.axisIterator(Axis.ATTRIBUTE);
		while (attrs.hasNext()) {
			XdmNode attr = (XdmNode) attrs.next();
			if (attributes.contains(attr.getNodeName().toString()) || attributes.contains(attr.getNodeName().getLocalName())) {
				uncounted.add(attr);
			}
		}
		Iterator<XdmItem> children = root.axisIterator(Axis.CHILD);
		while (children.hasNext()) {
			XdmNode child = (XdmNode) children.next();
			uncounted.add(child);
			addAll(child, attributes);
		}
	}
	
	@SuppressWarnings("serial")
	public static class AlreadyCountedException extends RuntimeException {
		public AlreadyCountedException(String message) { super(message); }
	}
	
	public int count(String path) throws AlreadyCountedException, SaxonApiException {
		if (!path.startsWith("/"))
			path = "//" + path;
		XdmValue nodes = xml.get(path);
		for (XdmItem node : nodes) {
			boolean wasUncounted = uncounted.remove((XdmNode) node);
			if (!wasUncounted) throw new AlreadyCountedException(path);			
		}
		return nodes.size();
	}
	public int count(List<String> paths) throws AlreadyCountedException, SaxonApiException {
		int count = 0;
		for (String path : paths) count += count(path);
		return count;
	}
	
	public Map<String, Set<XdmNode>> getUncounted() {
		Map<String, Set<XdmNode>> counter = new HashMap<String, Set<XdmNode>>();
		for (XdmNode node : uncounted) {
			if (node.getNodeName() == null) continue;
			String name = node.getNodeName().toString();
			if (!counter.containsKey(name)) counter.put(name, new HashSet<XdmNode>());
			counter.get(name).add(node);
		}
		return counter;
	}

	public Map<String, Integer> getUncountedCounts() {
		Map<String, Integer> counter = new HashMap<String, Integer>();
		for (Map.Entry<String, Set<XdmNode>> entry : getUncounted().entrySet())
			counter.put(entry.getKey(), entry.getValue().size());
		return counter;
	}
}
