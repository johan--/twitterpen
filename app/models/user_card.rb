class UserCard < ActiveRecord::Base
  belongs_to :user
  has_many :post_payments

  validates_presence_of :user, :stripe_card_id, :stripe_fingerprint, :stripe_token,
                        :last4, :card_type, :exp_month, :exp_year, :name

  before_create :stripe_create_card
  before_update :stripe_update_card
  before_destroy :stripe_destroy_card

  def stripe_create_card
    # Set card as active, as this is the default state
    self.is_active = true

    customer = self.user.stripe_customer

    # Check if the card is already present in Stripe
    fingerprint_card = customer.cards.data.detect { |card| card['fingerprint'] == self.stripe_fingerprint }

    # If the card is not present in Stripe - create it
    if fingerprint_card.blank?
      logger.debug "[stripe] Add new card"
      customer.cards.create(card: self.stripe_token)
      self.is_default = (customer.cards.data.size == 0)

      return true

    # If the card is present in Stripe, but missing locally - create it.
    # This is usually the case with the first transaction.
    else
      card = UserCard.find_by_stripe_fingerprint(self.stripe_fingerprint)

      if card.blank?
        logger.debug "[stripe] Add card in database only"
        self.is_default = (customer.cards.data.size == 1)
        return true
      else
        logger.debug "[stripe] Skip card, already in customer's profile"
        return false
      end
    end
  end

  def stripe_update_card
    logger.debug "[stripe] Update card on Stripe"
  end

  def stripe_destroy_card
    logger.debug "[stripe] Remove card from Stripe and database"
    customer = self.user.stripe_customer
    customer.cards.retrieve(self.stripe_card_id).delete()
  end

  private :stripe_create_card, :stripe_update_card, :stripe_destroy_card

end
