class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :members, dependent: :nullify
  has_many :groups, through: :members

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  # メンバー名のデフォルト表示名（未設定ならメールのローカル部）
  def display_name
    name.presence || email_address.to_s.split("@").first
  end
end
