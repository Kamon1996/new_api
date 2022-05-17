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

    context 'before user is created' do
      it 'user has email' do
        user = User.new(email: '', password: '123456')
        expect(user).to_not be_valid
        user.email = 'test@test.com'
        expect(user).to be_valid
      end

      it 'user has correct email' do
        user = User.new(email: 'asd', password: '123456')
        expect(user).to_not be_valid
        user.email = 'test@'
        expect(user).to_not be_valid
        user.email = 'test@as.'
        expect(user).to_not be_valid
        user.email = 'test@as.1'
        expect(user).to_not be_valid
        user.email = 'testas.1'
        expect(user).to_not be_valid
        user.email = 'testas.'
        expect(user).to_not be_valid
        user.email = 't@.t.t'
        expect(user).to_not be_valid
        user.email = 'test@test.test'
        expect(user).to be_valid
      end

      it 'user has unique email' do
        user_first = User.first_or_create(email: 'test@test.test', password: '123456')
        user_second = User.new(email: user_first.email, password: '123456')
        expect(user_second).to_not be_valid
        user_second.email = 'test1@test.com'
        expect(user_second).to be_valid
      end

      it 'user has password' do
        user = User.new(email: 'test@test.test', password: '')
        expect(user).to_not be_valid
        user.password = '12345678'
        expect(user).to be_valid
      end

      it 'user has valid password length' do
        user = User.new(email: 'test@test.test', password: '12345')
        expect(user).to_not be_valid
        user.password = '  2'
        expect(user).to_not be_valid
        user.password = '123456'
        expect(user).to be_valid
      end
  end
end
