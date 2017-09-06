class Spree::Report::SalesForClient < Spree::Report
  def self.headers
    [
      Spree.t(:sku), Spree.t(:name), Spree.t(:brand), Spree.t(:taxons), Spree.t(:quantity), Spree.t(:unit_price), Spree.t(:total),
      Spree.t(:email), Spree.t(:client_name), Spree.t(:address), Spree.t(:state_address), Spree.t(:order)
    ]
  end

  def self.compute(dates)
    Spree::LineItem.
      select("spree_line_items.id AS line_item_id, spree_variants.id, spree_products.id AS product_id,
              spree_variants.sku, COALESCE(spree_variants.variant_name, spree_products.name) as name,
              spree_line_items.quantity,
              (spree_line_items.price +  spree_line_items.adjustment_total/spree_line_items.quantity) AS unit_price,
              (spree_line_items.price * spree_line_items.quantity + spree_line_items.adjustment_total) AS total,
              spree_orders.email, spree_addresses.firstname, spree_addresses.lastname, spree_addresses.address1, spree_addresses.address2,
              ARRAY_AGG(DISTINCT(spree_orders.id)) AS order_ids,
              spree_orders.number AS order_number,
              spree_states.name AS state_address,
              ARRAY_AGG(DISTINCT(spree_taxons.name)) AS taxons, ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values").
      joins(order: [:payments, :bill_address]).
      joins("INNER JOIN spree_variants ON spree_variants.id = spree_line_items.variant_id").
      joins("INNER JOIN spree_products ON spree_variants.product_id = spree_products.id").
      joins("LEFT JOIN spree_states ON spree_addresses.state_id = spree_states.id").
      joins("LEFT JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id LEFT JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id").
      joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
      where(spree_orders: { state: :complete, completed_at: dates }).
      where(spree_payments: { state: :completed }).
      group("spree_line_items.id, spree_variants.id, spree_products.id, spree_variants.sku, spree_line_items.quantity, spree_line_items.price,
        spree_addresses.firstname, spree_addresses.lastname, spree_addresses.address1, spree_addresses.address2, county, state_address, spree_orders.number, spree_orders.email")
  end

  def self.to_csv(dates)
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute(dates).each do |item|
        values = []

        values << item[:sku]
        values << item[:name]
        values << brand(item)
        values << item[:taxons].join(', ')
        values << item[:quantity]
        values << display_money(item[:unit_price])
        values << display_money(item[:total])
        values << item[:email]
        values << full_name(item)
        values << full_address(item)
        values << item[:state_address]
        values << item[:order_number]

        csv << values
      end
    end
  end

end
