package com.adviser.schrisch.model.dto

import com.adviser.schrisch.Config
import com.adviser.schrisch.model.Attribute
import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.DataCenters
import com.adviser.schrisch.model.Ip
import com.adviser.schrisch.model.Port
import com.adviser.schrisch.model.Rack
import com.adviser.schrisch.model.Space
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import java.net.URI
import javax.mail.URLName
import org.eclipse.jetty.client.HttpClient
import org.eclipse.jetty.client.util.BasicAuthentication
import java.beans.PropertyChangeListener

class RackTablesApi {

	//static val LOGGER = LoggerFactory.getLogger(RackTablesApi)

	val objectMapper = new ObjectMapper()

	val httpClient = new HttpClient()

	val Config config

	new(Config _config) {
		config = _config
		httpClient.start()
	}

	def request(String url) {
		val uri = config.apiurl + url
		val p_url = new URLName(uri)
		var e_url = p_url.protocol + "://" + p_url.host + (if(p_url.port > 0) {
			":" + p_url.port
		} else {
			""
		}) + "/" + p_url.file
		httpClient.getAuthenticationStore().addAuthentication(
			new BasicAuthentication(new URI(e_url), "RacktablesAuthenticator", p_url.username, p_url.password));
		val response = httpClient.GET(e_url)
		objectMapper.readValue(response.content, JsonNode);
	}

	def load_content_from_racktables(PropertyChangeListener[] pcls, JsonNode in_content) {
		val content = Content.create(pcls,
			in_content.findValue('name').asText,
			in_content.findValue('label').asText,
			in_content.findValue('asset_no').asText,
			in_content.findValue('type').asText,
			in_content.findValue('tags').asText,
			in_content.findValue('has_problems').asBoolean,
			in_content.findValue('id').asText
		)
		in_content.findValue('ports').forEach[port|
			content.ports.add(
				Port.create(pcls, port.findValue('name').asText, port.findValue('label').asText,
					port.findValue('type').asText, port.findValue('remote_port').asText,
					port.findValue('l2address').asText, port.findValue('cable').asText))]

		in_content.findValue('spaces').forEach[space|
			content.spaces.add(Space.create(pcls, space.findValue('unit_no').asText, space.findValue('atom').asText))]

		in_content.findValue('ips').forEach[ip|
			content.ips.add(
				Ip.create(pcls, ip.findValue('version').asText, ip.findValue('type').asText,
					ip.findValue('ip').findValue('address').asText + "/" + ip.findValue('ip').findValue('prefix'),
					ip.findValue('name').asText, ip.findValue('address').asText))]

		in_content.findValue('attributes').fieldNames.forEach[fieldName|
			content.attributes.add(
				Attribute.create(pcls,
					fieldName,
					in_content.findValue('attributes').findValue(fieldName).asText
				))]
		return content
	}

	def load_from_rack_racktables(PropertyChangeListener[] pcls, JsonNode in_rack) {
		val rack = Rack.create(pcls, in_rack.findValue('name').asText, in_rack.findValue('height').asInt,
			in_rack.findValue('comment').asText, in_rack.findValue('row').asText)

		request(in_rack.findValue('content').findValue('__ref__').asText).forEach [ in_content |
			rack.contents.add(load_content_from_racktables(pcls, in_content))
		]
		return rack
	}

	def static loadFromRackTables(Config config, PropertyChangeListener[] pcls) {
		(new RackTablesApi(config)).load_datacenters(config, pcls)
	}

	def load_datacenters(Config config, PropertyChangeListener[] pcls) {
		val dataCenters = new DataCenters(pcls)
		val dataCenter = dataCenters.add(new DataCenter(pcls))
		request("/rack").forEach [ in_rack |
			dataCenter.racks.add(load_from_rack_racktables(pcls, in_rack))
		]
		return dataCenters
	}

}
