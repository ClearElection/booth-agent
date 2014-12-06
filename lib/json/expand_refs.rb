module JSON
  def self.expand_refs!(json)
      json.tap {
        JSON.recurse_proc json do |item|
          if Hash === item and uri = item['$ref']
            uri = URI.parse(uri)
            source = case uri.scheme
                    when nil then nil
                    when 'file' then ClearElection::Schema.root.join uri.path.sub(%r{^/}, '')
                    else uri
                    end
            if source
              item.delete '$ref'
              item.merge! expand_refs! JSON.parse source.read
            end
          end
        end
      }
  end
end
