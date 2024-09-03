module Schoolizable

  def link_to_list
    # Student Case:
    href = "/admin/#{self.model_name.param_key}?f[schools][39981][v]=#{self.school.short_name}" 
    # Others Cases:
    href = "/admin/#{self.model_name.param_key}?f[school][38030][o]=like&f[school][38030][v]=#{self.school.short_name}"
    name = I18n.t("activerecord.models.#{self.model_name.param_key}.other")
    ApplicationController.helpers.label_link_with_tooltip(href, 'bg-info me-1', "<i class='fa #{icon_entity}'></i>", "#{name} de #{school.short_name&.titleize}")
  end
end
