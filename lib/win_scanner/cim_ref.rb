module WinScanner

  class CIMRef
    def initialize(client, uri, selectors)
      @client = client
      @uri = uri
      @selectors = selectors
      @instance = nil
    end

    def to_s
      "Ref #{@uri}?#{@selectors.map { |k,v| "#{k}=#{v}" }.join('&')}"
    end

    def method_missing(name, *args)
      unless @instance
        options = Openwsman::ClientOptions.new
        @selectors.each do |key, val|
          options.add_selector(key, val)
        end

        result = @client.get(options, @uri)
        if result.fault?
          raise result
        end
        body = result.body
        node = body.first
        @instance = CIMInstance.new(@client, node)
      end
      @instance.send(name, args)
    end
  end

end
