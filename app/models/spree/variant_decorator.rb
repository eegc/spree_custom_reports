Spree::Variant.class_eval do

  scope :complete_order, -> { joins(:orders).where.not(spree_orders: { completed_at: nil }) }

  def self.sales_sku
    select("spree_variants.id, spree_variants.sku, spree_products.name, spree_variants.variant_name, SUM(spree_line_items.quantity) AS quantity, spree_prices.amount").
    joins(:product, :default_price).
    complete_order.
    group("spree_variants.id, spree_variants.sku, spree_products.name, spree_prices.amount, spree_variants.variant_name")
  end
end
