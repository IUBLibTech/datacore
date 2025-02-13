module Extensions
  module Hydra
    module AccessControls
      module Permission
        module EscapingObsoletions
          # unmodified from hydra-access-controls
          def agent_name
            ::URI.decode(parsed_agent.last)
          end
          # unmodified from hydra-access-controls
          def build_agent_resource(prefix, name)
            [::Hydra::AccessControls::Agent.new(::RDF::URI.new("#{prefix}##{::URI.encode(name)}"))]
          end
        end
      end
    end
  end
end
