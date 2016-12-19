class SystemStorage < ApplicationRecord
  def self.update_storage(category, content)
    item = self.find_by(category: category)
    if item.nil?
      self.create(category: category, content: content)
    else
      last_updated_at = item.updated_at
      item.update(content: content, last_updated_at: last_updated_at)
    end
  end

  def self.get_storage(category)
    self.find_by(category: category)
  end

end
