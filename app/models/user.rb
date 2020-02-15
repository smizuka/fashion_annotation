class User < ApplicationRecord
  validates :name, presence: {message: "%{value}を入力してください"}
  validates :password, presence: {message: "%{value}を入力してください"}
  validates :login_id, presence: {message: "%{value}を入力してください"}
  validates :user_type, presence: true
  validates :display_id, presence: true

  has_secure_password

  #名前の文字数制限
  validates :name, length: {maximum: 15, message: "は15文字以内にしてください"}

  #パスワードの文字数制限
  validates :password, length: {in: 8..32, too_long:"は32文字以内にしてください", too_short:"は8文字以上にしてください"}
  validates :password, format: {with: /(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)/, message: "%{value}はアルファベット（大小）と半角数字の混合にしてください"}

  #パスワードが一致しているかの確認
  validates :password, confirmation: {message: "とpasswordの値が一致していません"}

  #列挙型
  enum user_type: { admin: 0, inhouse: 1, outside: 2}
  enum display_id: { display: 0, block: 1, ban: 2}

  #アソシエーション
  has_many :editeds
  # has_many :edited_annotations, through: :edited, source: 'annotation'

  #生データのCSV出力の際に使用する
  def edited_annotations
    array = []
    editeds = Edited.where(user_id: self.id)

    editeds.each do | edited |
      anno = Annotation.find(edited.annotation_id)
      array.push([edited.annotation_id, self.name, anno.folder_name, anno.path, edited.information])
    end

    return array
  end

  has_many :allocations
  # has_many :allocation_annotations, through: :allocations, source: 'annotation'

  def allocation_annotations
    array = []
    allocations = Allocation.where(user_id: self.id, state: "working")

    for allocation in allocations
      content = Annotation.find(allocation.annotation_id)
      array.push(content)
    end

    return array
  end

end
