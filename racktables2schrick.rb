
require 'yaml'
require 'net/http'
require 'json'
require 'ipaddress'
require 'fileutils'

CONFIG = YAML.load_file('config.yaml')

def api_request(path)
    uri = URI("#{CONFIG['api']['url']}#{path}")
    puts "load from: #{uri}"
    req = Net::HTTP::Get.new(uri)
    req.basic_auth(uri.user, uri.password) if uri.user and uri.password
    Net::HTTP.start(uri.hostname, uri.port) {|http|
        response = http.request(req)
        return JSON.parse(response.body.encode("ISO-8859-1","UTF-8"))
    }
end
def write_str(str, *path)
  path = File.join("schrisch", *path)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, 'w') {|f| f.write(str) }
  puts "Write:#{path}"
  return str
end

def clean_fname(fname)
  fname.downcase.gsub(/[^a-z0-9]+/, '-')
end

class Racks
  class Rack
    attr_accessor :name, :height, :comment, :row, :content, :unknown, :contents
    def initialize
      @contents = {}
    end
    class Content
      attr_accessor :name, :label, :asset_no, :type, :tags, :spaces, :ports, :ips, :has_problems, :attributes, :unknown, :id
      class Space
        attr_accessor :unit_no, :atom, :unknown
        def self.load_from_racktables(space)
          my = Space.new
          my.unit_no = space.delete('unit_no')
          my.atom = space.delete('atom')
          my.unknown = space
          my
        end
      end
      class Port
        attr_accessor :name, :label, :type, :remote_port, :l2address, :cable, :unknown
        def self.load_from_racktables(port)
          my = Port.new
          my.name = port.delete('name')
          my.label = port.delete('label')
          my.type = port.delete('type')
          my.remote_port = port.delete('remote_port')
          my.l2address = port.delete('l2address')
          my.cable = port.delete('cable')
          my.unknown = port
          my
        end
      end
      class Ip
        attr_accessor :version, :type, :ip, :name, :address, :unknown
        def self.load_from_racktables(ip)
          my = Ip.new
          my.version = ip.delete('version')
          my.type = ip.delete('type')
          tmp = ip.delete('ip')
          my.ip = IPAddress.parse("#{tmp['address']}/#{tmp['prefix']}")
          my.name = ip.delete('name')
          my.address = ip.delete('address')
          my.unknown = ip
          my
        end
      end
      def ident
        clean_fname(if name && !name.strip.empty?
          name
        else
          id.to_s
        end)
      end
      def self.load_from_racktables(content)
        my = Content.new
        my.name = content.delete('name')
        my.label = content.delete('label')
        my.asset_no = content.delete('asset_no')
        my.type = content.delete('type')
        my.tags = content.delete('tags')
        my.spaces = content.delete('spaces').map{|i| Space.load_from_racktables(i) }
        my.ports = content.delete('ports').map{|i| Port.load_from_racktables(i) }
        my.ips = content.delete('ips').map{|i| Ip.load_from_racktables(i) }
        my.has_problems = content.delete('has_problems')
        my.attributes = content.delete('attributes')
        my.id = content.delete('id')
        my.unknown = content
        my
      end
    end
    def ident
      clean_fname(row+"-"+name)
    end
    def self.load_from_racktables(rack)
      my = Rack.new
      my.name = rack.delete('name')
      my.height = rack.delete('height')
      my.comment = rack.delete('comment')
      my.row = rack.delete('row')
      api_request(rack.delete('content')['__ref__']).each do |rt_content|
        content = Content.load_from_racktables(rt_content)
#puts "#{content.ident}"
        throw "content name exists #{content.ident}" if my.contents[content.ident]
        my.contents[content.ident] = content
      end
      my.unknown = rack
      my
    end
  end
  def initialize
    @racks = {}
  end
  def load_from_racktables
    api_request("/rack").each do |rt_rack|
      rack = Rack.load_from_racktables(rt_rack)
#puts rack.ident
      throw "rack name exists #{rack.name}" if @racks[rack.ident]
      @racks[rack.ident] = rack
    end
  end
  def write_schrisch
    @racks.values.each do |rack|
      write_str(rack.to_yaml, ["#{rack.ident}.rack"])
      rack.contents.values.each do |content|
        write_str(content.to_yaml, "#{rack.ident}", "#{content.ident}.content")
      end
    end
  end
end

racks = Racks.new
racks.load_from_racktables
racks.write_schrisch


