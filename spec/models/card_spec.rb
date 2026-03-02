require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:owner).in_array(%w[A B]) }
  end

  describe 'アソシエーション' do
    it { is_expected.to have_many(:template_items) }
    it { is_expected.to have_many(:sheet_items) }
  end
end
