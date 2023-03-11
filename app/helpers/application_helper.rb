module ApplicationHelper
	def render_haml(haml, locals = {})
		Haml::Engine.new(haml.strip_heredoc, format: :html5).render(self, locals)
	end

	def label_status(klazz, content)
		capture_haml{"<span class='text-center badge #{klazz}'>#{content}</span>".html_safe }
	end

	def label_status_with_tooptip(klazz, content, title, placement='top')

		content_tag :b, rel: :tooltip, 'data-bs-toggle': 'tooltip', 'data-bs-placement': placement, 'data-bs-original-title': title do
			capture_haml{"<span class='text-center badge #{klazz}'>#{content}</span>".html_safe }
		end
	
	end

end
