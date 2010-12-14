require 'win_scanner/cim_ref'

module WinScanner

  class CIMInstance
    def initialize(client, node)
      @client = client
      @node = node
    end

    def method_missing(name, *args)
      obj = @node.send(name)
      if (obj.ReferenceParameters)
        params = obj.ReferenceParameters
        selectors = {}
        params.SelectorSet.each do |node|
          key = node.attr_find(nil, "Name")
          val = node.text
          selectors[key] = val
        end
        # FIXME the bindings should convert ResourceURI
        return CIMRef.new(@client, params.ResourceURI.text, selectors)
      end
      return obj.text
    end

  end

end
