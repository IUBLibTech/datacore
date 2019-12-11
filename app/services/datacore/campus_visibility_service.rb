module Datacore
  class CampusVisibilityService < Hyrax::QaSelectService
    def initialize
      super('iu_campuses')
    end

    def include_current_value(value, _index, render_options, html_options)
      unless value.blank? || active?(value)
        html_options[:class] << ' force-select'
        render_options += [[label(value), value]]
      end
      [render_options, html_options]
    end

    def active_ids
      active_elements.map { |e| [e[:id]] }
    end

    def active_ldap
      # FIXME
      ldap_map = {iub: 'BL', iupui: 'IN', iue: 'EA', iufw: 'FW',
                  iuk: 'KO', iun: 'NW', iusb: 'SB', ius: 'SE'}
      active_elements.map { |e| [ e[:id], ldap_map[e[:id]] ] }
    end
  end
end
