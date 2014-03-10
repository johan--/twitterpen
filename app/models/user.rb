class User < ActiveRecord::Base
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:twitter]

  has_many :posts
  has_many :post_payments

  ##instance methods

  def self.find_for_twitter_oauth(auth, role, signed_in_resource = nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    if user
      return user
    else
      registered_user = User.where(email: auth.uid + "@twitter.com").first
      if registered_user
        return registered_user
      else
        user = User.create(
          name: auth.info.name,
          provider: auth.provider,
          uid: auth.uid,
          email: auth.uid + "@twitter.com",
          password: Devise.friendly_token[0,20]
        )

        user.add_role role

        user
      end
    end
  end

  def stripe_get_default_card
    if self.stripe_customer_id?
      customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      (customer.default_card.present? ? customer.cards.retrieve(customer.default_card) : nil)
    end
  end
end
