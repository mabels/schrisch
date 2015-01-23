package com.adviser.schrisch.model.dto

import com.adviser.schrisch.ImportRackTables
import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.Ip
import com.adviser.schrisch.model.Port
import com.adviser.schrisch.model.Rack
import com.adviser.schrisch.model.Space
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import java.util.HashMap
import org.eclipse.jetty.client.HttpClient
import org.slf4j.LoggerFactory
import org.eclipse.jetty.client.util.BasicAuthentication
import javax.mail.URLName
import java.net.URI

class RackTablesApi {

	static val LOGGER = LoggerFactory.getLogger(RackTablesApi)

	val objectMapper = new ObjectMapper()

	val httpClient = new HttpClient()

	val ImportRackTables.Config config

	new(ImportRackTables.Config _config) {
		config = _config
		httpClient.start()
	}

	def request(String url) {
		val uri = config.apiurl + url
		val p_url = new URLName(uri)
		var e_url = p_url.protocol+"://"+p_url.host+(if (p_url.port > 0) { ":"+p_url.port } else { "" })+"/"+p_url.file
		httpClient.getAuthenticationStore().addAuthentication(new BasicAuthentication(new URI(e_url), "RacktablesAuthenticator", p_url.username, p_url.password));
		val response = httpClient.GET(e_url)
		objectMapper.readValue(response.content, JsonNode);
	}

	def load_attributes_from_racktables(JsonNode attributes) {
		val ret = new HashMap<String, String>
		attributes.fieldNames.forEach [ fieldName |
			ret.put(fieldName, attributes.findValue(fieldName).asText)
		]
		ret
	}

	def load_content_from_racktables(Rack rack, JsonNode content) {
		new Content(
			rack, 
			content.findValue('name').asText,
			content.findValue('label').asText,
			content.findValue('asset_no').asText,
			content.findValue('type').asText,
			content.findValue('tags').asText,
			content.findValue('spaces').map [ space |
				new Space(space.findValue('unit_no').asText, space.findValue('atom').asText)
			],
			content.findValue('ports').map [ port |
				new Port(
					port.findValue('name').asText,
					port.findValue('label').asText,
					port.findValue('type').asText,
					port.findValue('remote_port').asText,
					port.findValue('l2address').asText,
					port.findValue('cable').asText
				)
			],
			content.findValue('ips').map [ ip |
				new Ip(
					ip.findValue('version').asText,
					ip.findValue('type').asText,
					ip.findValue('ip').findValue('address').asText + "/" + ip.findValue('ip').findValue('prefix'),
					ip.findValue('name').asText,
					ip.findValue('address').asText
				)
			],
			content.findValue('has_problems').asBoolean,
			load_attributes_from_racktables(content.findValue('attributes')),
			content.findValue('id').asText
		)
	}

	def load_from_rack_racktables(DataCenter dataCenter, JsonNode in_rack) {
		val name = in_rack.findValue('name').asText
		val height = in_rack.findValue('height').asInt
		val comment = in_rack.findValue('comment').asText
		val row = in_rack.findValue('row').asText
		val contents = new HashMap<String, Content>()
		val rack = new Rack(dataCenter, name, height, comment, row, contents)

		request(in_rack.findValue('content').findValue('__ref__').asText).forEach [ in_content |
			val content = load_content_from_racktables(rack, in_content)
			contents.put(content.ident, content)
		]
		rack
	}

	def static loadFromRackTables(ImportRackTables.Config config) {
		(new RackTablesApi(config)).load_datacenter
	}
	
	def load_datacenter() {	
		val racks = new HashMap<String, Rack>
		val dataCenter = new DataCenter(racks)
		request("/rack").forEach [ in_rack |
			val rack = load_from_rack_racktables(dataCenter, in_rack)
			racks.put(rack.ident, rack)
		]
		return dataCenter
	}

}
