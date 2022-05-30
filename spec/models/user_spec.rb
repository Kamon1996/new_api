# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string
#  nickname               :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sername                :string
#  tokens                 :text
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  context 'before user is created' do
    it 'should has a valid email' do
      wrong_emails = ['test@', 'test@as.', 'test@as.1', 'testas.1', 'testas.',
                      't@.t.t']
      wrong_emails.each do |email|
        user.email = email
        expect(user).to_not be_valid
      end
      user.email = 'test@test.test'
      expect(user).to be_valid
    end

    it 'should has a unic email' do
      user_first = create(:user)
      user.email = user_first.email
      expect(user).to_not be_valid
      user.email = 'test1@test.com'
      expect(user).to be_valid
    end

    it 'should has a valid password' do
      user.password = ''
      expect(user).to_not be_valid
      user.password = '12345'
      expect(user).to_not be_valid
      user.password = '  2'
      expect(user).to_not be_valid
      user.password = '123456'
      expect(user).to be_valid
    end
  end
end
