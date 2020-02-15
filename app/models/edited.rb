class Edited < ApplicationRecord
    validates :user_id, presence: true
    validates :annotation_id, presence: true
    validates :path, presence: true
    validates :information, presence: true

    belongs_to :user
end
