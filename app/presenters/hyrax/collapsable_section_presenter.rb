require File.join(Gem::Specification.find_by_name("hyrax").full_gem_path, "app/presenters/hyrax/collapsable_section_presenter.rb")

# monkey patch Hyrax::WorkShowPresenter
module Hyrax

  class CollapsableSectionPresenter

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
