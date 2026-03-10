require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "email_address と password があれば有効" do
      user = User.new(email_address: "test@example.com", password: "password123")
      expect(user).to be_valid
    end

    it "email_address がなければ無効" do
      user = User.new(email_address: "", password: "password123")
      expect(user).not_to be_valid
    end

    it "email_address が重複していれば無効" do
      User.create!(email_address: "test@example.com", password: "password123")
      user = User.new(email_address: "test@example.com", password: "password123")
      expect(user).not_to be_valid
    end

    it "password がなければ無効" do
      user = User.new(email_address: "test@example.com", password: "")
      expect(user).not_to be_valid
    end
  end

  describe "アソシエーション" do
    it "setting に belongs_to する（任意）" do
      assoc = described_class.reflect_on_association(:setting)
      expect(assoc).not_to be_nil
      expect(assoc.options[:optional]).to be true
    end

    it "複数の sessions を持つ" do
      assoc = described_class.reflect_on_association(:sessions)
      expect(assoc).not_to be_nil
    end
  end
end
