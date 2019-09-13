ActiveAdmin.register Bot do
  permit_params :name, :active, :info, :purpose, :image

  show do
    attributes_table do
      row :id
      row :name
      row :active
      row :info
      row :image do |resource|
        if resource.image.attached?
          image_tag resource.image
        end
      end
      row :image_telegram_id
      row :purpose
    end
  end

  form do |f|
    f.inputs 'Bot params' do
      f.input :name
      f.input :active
      f.input :info
      f.input :purpose
      f.input :image, as: :file

      f.submit
    end
  end
end