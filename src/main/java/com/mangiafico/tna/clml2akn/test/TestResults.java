package com.mangiafico.tna.clml2akn.test;

import java.io.Serializable;
import java.util.LinkedList;
import java.util.List;


public class TestResults {
	
	@SuppressWarnings("serial")
	public static class ElementCount implements Serializable {
		private List<String> paths;
		private int count;
		public ElementCount() { }
		public ElementCount(List<String> paths, int count) {
			this();
			this.paths = paths;
			this.count = count;
		}
		public ElementCount(final String path, int count) {
			this();
			this.paths = new LinkedList<String>() {{ add(path); }};
			this.count = count;
		}
		public List<String> getPaths() { return paths; }
		public int getCount() { return count; }
		public String toString() {
			return paths.toString() + ", " + count;
		}
	}

	@SuppressWarnings("serial")
	public static class ElementMapping implements Serializable {
		private ElementCount clml;
		private ElementCount akn;
		public ElementMapping() { }
		public ElementMapping(ElementCount clml, ElementCount an) {
			this();
			this.clml = clml;
			this.akn = an;
		}
		public ElementCount getClml() { return clml; }
		public ElementCount getAkn() { return akn; }
		public String toString() {
			return (clml == null ? "" : clml.toString()) + " --> " + (akn == null ? "" : akn.toString());
		}
	}
	
	private List<ElementMapping> pairings;
	private float score;
	
	private static float score(List<ElementMapping> pairings) {
		int good = 0, bad = 0;
		for (ElementMapping pairing : pairings) {
			if (pairing.akn == null) {
				bad += pairing.clml.count;
			} else if (pairing.clml == null) {
				bad += pairing.akn.count;
			} else {
				good += pairing.clml.count < pairing.akn.count ? pairing.clml.count : pairing.akn.count;
				bad += Math.abs(pairing.clml.count - pairing.akn.count);
			}
		}
		return (float) good / (good + bad) * 100;
	}
	
	TestResults(List<ElementMapping> pairings) {
		this.pairings = pairings;
		this.score = score(pairings);
	}

	public List<ElementMapping> getPairings() {
		List<ElementMapping> nonzero = new LinkedList<ElementMapping>();
		for (ElementMapping em : pairings)
			if (em.clml == null || em.akn == null || em.clml.count > 0 || em.akn.count > 0) nonzero.add(em);
		return nonzero;

	}
	public List<ElementMapping> getUnequalPairings() {
		List<ElementMapping> unequal = new LinkedList<ElementMapping>();
		for (ElementMapping em : pairings)
			if (em.clml == null || em.akn == null || em.clml.count != em.akn.count) unequal.add(em);
		return unequal;
	}
	public float getScore() { return score; }

}
