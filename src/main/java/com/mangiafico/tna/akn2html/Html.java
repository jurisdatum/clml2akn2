package com.mangiafico.tna.akn2html;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.List;
import java.util.stream.Collectors;

import javax.json.Json;
import javax.json.JsonObject;

public class Html {
	
	private static String read(InputStream stream) {
		try (java.util.Scanner s = new java.util.Scanner(stream)) {
			return s.useDelimiter("\\A").hasNext() ? s.next() : "";
		}
	}
	
	public static class HTTPException extends IOException {
		public final int status;
		private HTTPException(int status) {
			super("HTTP status " + status);
			this.status = status;
		}
	}
	
	private static JsonObject post(URL url, String html) throws IOException {
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.setRequestMethod("POST");
		connection.setRequestProperty("Content-Type", "text/html");
//		connection.connect();
		
		connection.setDoOutput(true);
		connection.setDoInput(true);
		
		OutputStreamWriter out = new OutputStreamWriter(connection.getOutputStream(), Charset.forName("UTF-8"));
		new PrintWriter(out).println(html);
		out.close();
		String json;
		try {
			int responseCode = connection.getResponseCode();
			if (responseCode != 200)
				throw new HTTPException(responseCode);
			InputStream stream = connection.getInputStream();
			try {
				json = read(stream);
			} finally {
				stream.close();
			}
		} finally {
			connection.disconnect();
		}
//		System.out.println(json);
		return Json.createReader(new StringReader(json)).readObject();
	}
	
	public static class Results2 {
		
		private final JsonObject json;
		
		private Results2(JsonObject json) {
			this.json = json;
		}
		
		public static class Message2 {

			private final JsonObject json;
			
			private Message2(JsonObject json) {
				this.json = json;
			}
			
			public String getType() {
				return json.getString("type");
			}
			public String getMessage() {
				return json.getString("message");
			}
			public int getLine() {
				return json.getInt("lastLine");
			}
			public int getColumn() {
				return json.getInt("firstColumn");
			}
			public String getExtract() {
				return json.getString("extract");
			}
			
			public void print(PrintStream out) {
				out.print("line ");
				out.print(getLine());
				out.print(": ");
				out.print(getMessage());
				out.println();
			}

		}
		
		public List<Message2> getMessages() {
			return json.getJsonArray("messages").getValuesAs(JsonObject.class).stream()
				.map(Message2::new).collect(Collectors.toList());
		}
		public List<Message2> getErrors() {
			return getMessages().stream().filter(m -> m.getType().equals("error")).collect(Collectors.toList());
		}

		public JsonObject asJson() {
			return json;
		}

		public String toString() {
			return json.toString();
		}

	}
	
	public static Results2 validate(String html) throws IOException {
//		URL url = new URL("http://html5.validator.nu/?out=xml");
		URL url = new URL("http://validator.nu/" + "?schema=http://s.validator.nu/html5-rdfalite.rnc+http://s.validator.nu/html5/assertions.sch+http://c.validator.nu/all/" + "&parser=html" + "&out=json");
		JsonObject json = post(url, html);
		return new Results2(json);
	}

}
