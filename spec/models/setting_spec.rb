require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:member_a) }
    it { is_expected.to validate_presence_of(:member_b) }
  end
end
