# modified from hyrax 2.9.6: added aria-label attribute
module Extensions
  module Hyrax
    module CollapsableSectionPresenter
      module CollapsableSectionPresenterBehavior
        private
        def button_tag
          content_tag(:a,
                      role: 'button',
                      class: "#{button_class}collapse-toggle",
                      data: { toggle: 'collapse' },
                      href: "##{id}",
                      'aria-label' => "Expand / Collapse #{text}",
                      'aria-expanded' => open,
                      'aria-controls' => id) do
                        safe_join([content_tag(:span, '', class: icon_class, 'aria-hidden' => true),
                                   content_tag(:span, text)], ' ')
                      end
        end
      end
    end
  end
end
