module Extensions
  module Hydra
    module AccessControls
      module Permission
        module EscapingObsoletions
          # modified to use CGI method instead of obsolete URI method
          def agent_name
            ::CGI.unescape(parsed_agent.last)
          end

          # modified to use CGI method instead of obsolete URI method
          def build_agent_resource(prefix, name)
            [::Hydra::AccessControls::Agent.new(::RDF::URI.new("#{prefix}##{::CGI.escape(name)}"))]
          end
        end
      end
    end
  end
end
