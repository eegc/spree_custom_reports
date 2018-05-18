class Spree::Report::StockDetail < Spree::Report
  def self.headers
    [Spree.t(:sku), Spree.t(:brand), Spree.t(:name), Spree.t(:stock_location), Spree.t(:stock_available), Spree.t(:available_on)]
  end

  def self.compute
    Spree::Variant.
      select("spree_variants.id, spree_products.id AS product_id, spree_variants.sku, spree_products.name as name, spree_prices.amount,
        spree_stock_locations.name AS location_name,
        spree_stock_items.count_on_hand AS stock,
        spree_variants.deleted_at, spree_products.available_on, spree_products.deleted_at AS product_deleted_at,
        ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values,
        COALESCE(
          (
            SELECT SUM(quantity)
            FROM spree_line_items
            LEFT JOIN spree_orders ON spree_line_items.order_id = spree_orders.id
            WHERE spree_orders.completed_at IS NOT NULL AND spree_line_items.variant_id = spree_variants.id
          ), 0) AS total").
      joins(:product).
      joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
      joins(:default_price).
      joins(:stock_locations, :stock_items).
      # salable_variants.
      group("spree_variants.id, spree_products.id, spree_variants.sku, spree_prices.amount, location_name, stock, total, spree_variants.deleted_at, spree_products.available_on, spree_products.deleted_at").
      order("spree_variants.id, location_name, total DESC")
  end

  def self.to_csv
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute.each do |item|
        values = []

        values << item[:sku]
        values << brand(item)
        values << item[:name]
        values << item[:location_name]
        values << item[:stock]
        values << available(item)

        csv << values
      end
    end
  end

end
