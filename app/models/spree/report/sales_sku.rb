class Spree::Report::SalesSku < Spree::Report
  def self.headers
    [Spree.t(:sku), Spree.t(:name), Spree.t(:sales_items), Spree.t(:gross_price)]
  end

  def self.compute(dates)
    Spree::LineItem.
      select("spree_line_items.variant_id, spree_products.id AS product_id, spree_variants.sku,
              COALESCE(spree_variants.variant_name, spree_products.name) as name,
              ARRAY_AGG(DISTINCT(spree_orders.id)) AS order_ids,
              SUM(spree_line_items.quantity) AS items_quant,
              SUM(spree_line_items.price * spree_line_items.quantity + spree_line_items.adjustment_total) AS total").
      joins("INNER JOIN spree_variants ON spree_variants.id = spree_line_items.variant_id").
      joins("INNER JOIN spree_products ON spree_variants.product_id = spree_products.id").
      joins(order: :payments).
      where(spree_orders: { state: :complete, completed_at: dates }).
      where(spree_payments: { state: :completed }).
      group("spree_line_items.variant_id, spree_products.id, spree_variants.sku, spree_variants.variant_name, spree_products.name").order("total DESC")
  end

  def self.to_csv(dates)
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute(dates).each do |item|
        values = []

        values << item[:sku]
        values << item[:name]
        values << item[:items_quant]
        values << display_price(item[:total])

        csv << values
      end
    end
  end

end
