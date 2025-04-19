class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  enum role: { user: 'user', admin: 'admin' }
  after_initialize :set_default_role, if: :new_record?
  after_create :set_default_wallet_balance
       
  private
       
  def set_default_role
    self.role ||= :user
  end

  def set_default_wallet_balance
    self.wallet ||= (role == 'admin' ? 1000000 : 10000)
    save
  end
end
