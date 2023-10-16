# frozen_string_literal: true
# require 'rails_admin/config/actions'
# require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class Export < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        include ActionController::Live
        
        register_instance_option :collection do
          true
        end

        register_instance_option :http_methods do
          %i[get post]
        end

        register_instance_option :controller do
          proc do
            format = params[:json] && :json || params[:csv] && :csv || params[:xml] && :xml
            if format
              request.format = format
              @schema = HashHelper.symbolize(params[:schema].slice(:except, :include, :methods, :only).permit!.to_h) if params[:schema] # to_json and to_xml expect symbols for keys AND values.
              @objects = list_entries(@model_config, :export)
              index
            else
              render @action.template_name
            end
          end
        end


        # register_instance_option :controller do
        #   proc do

        #     begin
        #       format = params[:json] && :json || params[:csv] && :csv || params[:xml] && :xml
        #       if format
        #         response.headers.delete('Content-Length')
        #         response.headers['Cache-Control'] = 'no-cache'
        #         response.headers['X-Accel-Buffering'] = 'no'
        #         response.headers['Content-Type'] = 'text/event-stream'
        #         response.headers['ETag'] = '0'
        #         response.headers['Last-Modified'] = '0'
        #         aux = "Reporte Coes #{I18n.t("activerecord.models.#{params[:model_name]}.other")&.titleize} #{DateTime.now.strftime('%d-%m-%Y_%I:%M%P')}.xls"
        #         response.headers['Content-Disposition'] = "attachment; filename=#{aux}"
        #         request.format = format
        #         @schema = HashHelper.symbolize(params[:schema].slice(:except, :include, :methods, :only).permit!.to_h) if params[:schema] # to_json and to_xml expect symbols for keys AND values.
        #         @objects = list_entries(@model_config, :export)
        #         response.stream.write index
                
        #       end
        #     ensure
        #       response.stream.close
        #     end
        #   end
        # end


        register_instance_option :bulkable? do
          true
        end

        register_instance_option :link_icon do
          'fas fa-file-export'
        end
      end
    end
  end
end