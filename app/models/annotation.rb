class Annotation < ApplicationRecord
    validates :path, presence: true
    validates :category_id, presence: true
    validates :folder_name, presence: true
    validates :information, presence: true
    validates :state, presence: true

    #列挙型
    enum category_id: { Bird: 1, NonBird: 2, UnKnown: 3 }
    enum state: { unassigned: 1, working: 2, end: 3}

    def self.import(file)
        require "csv"
        CSV.foreach(file.path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
            Annotation.create(
              path: row['path'],
              category_id: row['category_id'].to_i,
              folder_name: row['folder_name'],
              information: row['information'],
              state: row['state'].to_i,
            )
        end
    end
end
