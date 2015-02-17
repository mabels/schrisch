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

  interface Request {
    public def byte[] request(String url)
  }
  
  static class HttpRequest implements Request {
    val Config config
    val httpClient = new HttpClient()
    
    
    new(Config _config) {
      config = _config
      httpClient.start()
    }
    
    override request(String url) {
      val uri = config.apiurl + url
      val p_url = new URLName(uri)
      var e_url = p_url.protocol + "://" + p_url.host + (if(p_url.port > 0) {
        ":" + p_url.port
      } else {
        ""
      }) + "/" + p_url.file
      httpClient.getAuthenticationStore().addAuthentication(
        new BasicAuthentication(new URI(e_url), "RacktablesAuthenticator", p_url.username, p_url.password));
      httpClient.GET(e_url).content     
    }
  }

  val Config config
  val Request dataSource 
  val objectMapper = new ObjectMapper() 

  new(Config _config) {
    config = _config
    dataSource = new HttpRequest(config)
  }
  
  new(Config _config, Request _request) {
    config = _config
    dataSource = _request
  }

  def request(String url) {
    objectMapper.readValue(dataSource.request(url), JsonNode);
  }

  def asNullableString(JsonNode js) {
    if (js.isNull) {
      return null
    } else {
      return js.asText
    }
  }

  def load_content_from_racktables(PropertyChangeListener[] pcls, JsonNode in_content) {
    val content = Content.create(
      pcls,
      asNullableString(in_content.findValue('name')),
      asNullableString(in_content.findValue('label')),
      asNullableString(in_content.findValue('asset_no')),
      asNullableString(in_content.findValue('type')),
      asNullableString(in_content.findValue('tags')),
      in_content.findValue('has_problems').asBoolean,
      asNullableString(in_content.findValue('id'))
    )
    in_content.findValue('ports').forEach[port|
      content.ports.add(
        Port.create(pcls, 
          asNullableString(port.findValue('name')), 
          asNullableString(port.findValue('label')),
          asNullableString(port.findValue('type')), 
          asNullableString(port.findValue('remote_port')),
          asNullableString(port.findValue('l2address')), 
          asNullableString(port.findValue('cable'))))]

    in_content.findValue('spaces').forEach[space|
      content.spaces.add(Space.create(pcls, 
        space.findValue('unit_no').asInt, 
        asNullableString(space.findValue('atom'))
      ))]

    in_content.findValue('ips').forEach[ip|
      content.ips.add(
        Ip.create(pcls, 
          asNullableString(ip.findValue('version')), 
          asNullableString(ip.findValue('type')),
          ip.findValue('ip').findValue('address').asText + "/" + ip.findValue('ip').findValue('prefix'),
          asNullableString(ip.findValue('name')), 
          asNullableString(ip.findValue('address'))))]

    in_content.findValue('attributes').fieldNames.forEach[fieldName|
      content.attributes.add(
        Attribute.create(
          pcls,
          fieldName,
          asNullableString(in_content.findValue('attributes').findValue(fieldName))
        ))]
    return content
  }

  def load_from_rack_racktables(PropertyChangeListener[] pcls, JsonNode in_rack) {
    val rack = Rack.create(pcls, 
      asNullableString(in_rack.findValue('name')), 
      in_rack.findValue('height').asInt,
      asNullableString(in_rack.findValue('comment')), 
      asNullableString(in_rack.findValue('row')))

    request(in_rack.findValue('content').findValue('__ref__').asText).forEach [ in_content |
      rack.contents.add(load_content_from_racktables(pcls, in_content))
    ]
    return rack
  }

  def static loadFromRackTables(Config config, PropertyChangeListener[] pcls) {
    (new RackTablesApi(config)).load_datacenters(pcls)
  }

  def load_datacenters(PropertyChangeListener[] pcls) {
    val dataCenters = new DataCenters(pcls)
    val dataCenter = dataCenters.add(new DataCenter(pcls))
    request("/rack").forEach [ in_rack |
      dataCenter.racks.add(load_from_rack_racktables(pcls, in_rack))
    ]
    return dataCenters
  }

}
