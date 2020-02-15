class Allocation < ApplicationRecord
    validates :user_id, presence: true
    validates :annotation_id, presence: true
    validates :folder, presence: true
    validates :state, presence: true

    enum state: { working: 0, end: 1}

    belongs_to :user
end
