class Tutorial < ApplicationRecord
  ## Relations
  belongs_to :group_tutorial 

  ## HISTORY:
  has_paper_trail on: [:create, :destroy, :update]
  before_create :paper_trail_create
  before_destroy :paper_trail_destroy
  before_update :paper_trail_update

  ## Rich Text
  has_rich_text :description

  ## Storage
  has_one_attached :video

  ## Validations
  validates :name_function, presence: true
  validates :video, presence: true

  rails_admin do
    list do
      field :id
      field :group_tutorial
      field :name_function
      field :video
      field :description
      field :created_at
      field :updated_at
    end		

    edit do
      field :group_tutorial
      field :name_function
      field :video
      field :description
    end		

    show do
      field :group_tutorial
      field :name_function
      field :video
      field :description
    end		
  end


  private
    def paper_trail_update
      changed_fields = self.changes.keys - ['created_at', 'updated_at']
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡#{object} actualizado en #{changed_fields.to_sentence}"
    end  

    def paper_trail_create
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡Tutorial creado!"
    end  

    def paper_trail_destroy
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡Tutorial eliminado!"
    end
end
