require 'openwsman/openwsman'
require 'win_scanner/cim_instance'

module WinScanner

  class Client

    BASE_URI = "http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2/"

    def initialize(opts={})
      opts[:host] ||= "localhost"
      opts[:username] ||= "wsman"
      opts[:password] ||= "secret"
      opts[:port] ||= 5985

      @wsclient = Openwsman::Client.new("http://#{opts[:username]}:#{opts[:password]}@#{opts[:host]}:#{opts[:port]}/wsman")
      @wsclient.transport.auth_method = Openwsman::BASIC_AUTH_STR
      @wsoptions = Openwsman::ClientOptions.new
      #@wsoptions.set_dump_request
      #Openwsman::debug = -1
    end

    def property(classname, property)
      each_value(classname, property) do |prop, values|
        return values.collect(&:to_s)
      end
      []
    end

    def each_instance(classname)
      uri = "#{BASE_URI}#{classname}"
      result = @wsclient.enumerate(@wsoptions, nil, uri)
      context = nil
      loop do
        context = result.context
        break unless context
        result = @wsclient.pull(@wsoptions, nil, uri, context)
        break unless result

        body = result.body
        if result.fault?
          raise result
          break
        end
        node = body.PullResponse.Items.send classname
        yield CIMInstance.new(@wsclient, node)
      end
      @wsclient.release(@wsoptions,uri,context) if context
    end

    def each_value(classname, property)
      uri = "#{BASE_URI}#{classname}"
      result = @wsclient.enumerate(@wsoptions, nil, uri)
      context = nil
      loop do
        context = result.context
        break unless context
        result = @wsclient.pull(@wsoptions, nil, uri, context)
        break unless result

        body = result.body
        if result.fault?
          raise result
          break
        end

        node = body.PullResponse.Items.send classname
        values = []
        Array(property).each do |p|
          values << node.send(p)
          yield(p, values)
        end
      end

      @wsclient.release(@wsoptions,uri,context) if context
    end

  end
end
