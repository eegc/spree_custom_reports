class Spree::Report::SalesAndStock < Spree::Report
  def self.headers
    [Spree.t(:sku), Spree.t(:description), Spree.t(:brand), Spree.t(:stock), Spree.t(:price), Spree.t(:taxons)]
  end

  def self.compute(dates)
    Spree::Variant.
      select("spree_variants.id, spree_products.id AS product_id, spree_variants.sku,
              COALESCE(spree_variants.variant_name, spree_products.name) as name,
              spree_stock_items.count_on_hand AS stock, spree_prices.amount,
              ARRAY_AGG(DISTINCT(spree_taxons.name)) AS taxons, ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values").
      joins(:product).
      joins("LEFT JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id LEFT JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id").
      joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
      joins(:default_price).
      joins(:stock_locations, :stock_items).
      joins(line_items: [order: :payments]).
      where(spree_orders: { state: :complete, completed_at: dates }).
      where(spree_payments: { state: :completed }).
      group("spree_variants.id, spree_products.id, spree_variants.sku, spree_prices.amount, stock")
  end

  def self.to_csv(dates)
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute(dates).each do |item|
        values = []

        values << item[:sku]
        values << item[:name]
        values << brand(item)
        values << item[:stock]
        values << display_money(item[:amount])
        values << item[:taxons].join(', ')

        csv << values
      end
    end
  end

end
