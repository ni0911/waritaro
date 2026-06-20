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
    it "members を経由して複数の groups に所属できる" do
      user = create(:user)
      g1 = create(:group)
      g2 = create(:group)
      create(:member, group: g1, user: user)
      create(:member, group: g2, user: user)
      expect(user.groups).to contain_exactly(g1, g2)
    end

    it "複数の sessions を持つ" do
      assoc = described_class.reflect_on_association(:sessions)
      expect(assoc).not_to be_nil
    end
  end

  describe "#display_name" do
    it "name があればそれを、なければメールのローカル部を返す" do
      expect(build(:user, name: "たろう").display_name).to eq("たろう")
      expect(build(:user, name: nil, email_address: "hanako@example.com").display_name).to eq("hanako")
    end
  end
end
