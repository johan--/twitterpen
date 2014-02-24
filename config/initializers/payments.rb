$payments = {
  currency: 'usd',

  # Internal payment statuses
  status: {
    not_paid: 0,
    paid: 1,
  },

  # Products
  product: {
    post_proofread: {
      id: 1,
      price: 99, # $0.99, price is in cents
      price_str: '$0.99',
    },
    post_edit: {
      id: 2,
      price: 2900,
      price_str: '$29',
    },
  },
}
