class BulmaFormBuilder < ActionView::Helpers::FormBuilder
  def bulma_form_element(form_method, attribute, options = {})
    label_text = options.delete(:label_text)
    no_label = options.delete(:no_label)
    class_list = @object.errors[attribute].present? ? [ "input", "is-danger", options[:class] ] : [ "input", options[:class] ]
    options[:class] = class_list.reject(&:nil?).join(" ")
    contents = control_helper(form_method, attribute, options)
    if @object.errors[attribute]
      contents = @object.errors[attribute].inject(contents) do |contents, error|
        contents + @template.content_tag(:p, error, class: "help is-danger")
      end
    end
    if options[:help_text]
      contents = contents + @template.content_tag(:p, options[:help_text], class: "help")
    end
    @template.content_tag(:div, class: "field") do
      unless no_label
        label(attribute, label_text || attribute.to_s.titleize, class: "label") + contents
      else
        contents
      end
    end
  end

  private
    def control_helper(form_method, attribute, options)
      icon_left = options.delete(:icon_left)
      @template.content_tag(:div, class: icon_left.nil? ? "control" : "control has-icons-left") do
        if icon_left.nil?
          ActionView::Helpers::FormBuilder.instance_method(form_method).bind(self).call(attribute, options)
        else
          ActionView::Helpers::FormBuilder.instance_method(form_method).bind(self).call(attribute, options) +
            @template.content_tag(:span, class: "icon is-small is-left") do
              @template.content_tag(:i, nil, class: icon_left)
            end
        end
      end
    end
end
