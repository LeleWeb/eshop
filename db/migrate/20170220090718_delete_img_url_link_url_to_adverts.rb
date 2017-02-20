class DeleteImgUrlLinkUrlToAdverts < ActiveRecord::Migration[5.0]
  def change
    remove_column :adverts, :img_url
    remove_column :adverts, :link_url
  end
end
