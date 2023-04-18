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

	def signatures

		capture_haml {
			".signatures
				.font-title.text-center FACULTAD
					%table.no_border
						%thead
							%tr
							%th.text-center{style: 'width: 500px'} JURADO EXAMINADOR
							%th.text-center{style: 'width: 500px'} SECRETARÍA
					%br
					%table.no_border
						%thead
							%tr
								%th APELLIDOS Y NOMBRES
								%th FIRMAS
								%th 
							%tr{style: 'height:30px'}
								%th _________________________________
								%th ______________________
								%th NOMBRE ______________________        
							%tr{style: 'height:30px'}
								%th _________________________________
								%th ______________________
								%th FIRMA _______________________
							%tr{style: 'height:30px'}
								%th _________________________________
								%th ______________________
								%th FECHA _______________________"
		}

	end	

end
