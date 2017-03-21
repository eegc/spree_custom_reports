class Spree::Report
  require 'csv'

  def self.variants_details
    Spree::Variant.
      select("spree_variants.id, spree_products.id AS product_id, spree_products.name as name, spree_variants.sku, spree_prices.amount as price, spree_variants.deleted_at, spree_products.available_on, spree_products.deleted_at AS product_deleted_at,
        ARRAY_AGG(DISTINCT(spree_taxons.name)) AS taxons, ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values").
      joins(:product, :default_price).
      joins("LEFT JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id LEFT JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id").
      joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
      group("spree_variants.id, spree_products.id, spree_products.name, spree_variants.sku, price, spree_variants.deleted_at, spree_products.available_on, product_deleted_at")
  end

  def self.stock_details
    Spree::Variant.
      select("spree_variants.id, spree_products.id AS product_id, spree_variants.sku, spree_products.name AS name, spree_prices.amount AS price, spree_stock_items.count_on_hand AS stock,
        COALESCE(
          (
            SELECT SUM(quantity)
            FROM spree_line_items
            LEFT JOIN spree_orders ON spree_line_items.order_id = spree_orders.id
            WHERE spree_orders.completed_at IS NOT NULL AND spree_line_items.variant_id = spree_variants.id
          ), 0) AS total,
        spree_variants.deleted_at, spree_products.available_on, spree_products.deleted_at AS product_deleted_at,
        ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values").
      joins(:product).
      joins("LEFT JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id LEFT JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id").
      joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
      joins(:default_price).
      joins(:stock_locations, :stock_items).
      group("spree_variants.id, spree_products.id, spree_variants.sku, spree_products.name, spree_prices.amount, stock, total, spree_variants.deleted_at, spree_products.available_on, spree_products.deleted_at").
      order("total DESC")
  end

  def self.sales_sku(dates)
    Spree::Variant.
      select("spree_variants.id, spree_products.id AS product_id, spree_variants.sku, spree_products.name, SUM(spree_line_items.quantity) AS sales_items, SUM(spree_line_items.price) AS amount").
      joins(:product).
      complete_order.
      where(spree_orders: { completed_at: dates }).
      group("spree_variants.id, spree_products.id, spree_variants.sku, spree_products.name").order("amount DESC")
  end

  def self.sales_for_state(dates)
    Spree::Order.
      select("UPPER(spree_states.name) AS state, UPPER(TRIM(spree_addresses.city)) AS city, COUNT(DISTINCT(spree_orders.id)) AS order_quantity, SUM(spree_orders.total) AS amount").
      joins(:bill_address).
      joins("LEFT JOIN spree_states ON spree_addresses.state_id = spree_states.id").
      complete.
      where(completed_at: dates).
      group("UPPER(spree_states.name), UPPER(TRIM(spree_addresses.city))")
  end

  def self.sales_for_product_and_client(dates)
    Spree::LineItem.
      select("spree_line_items.id, spree_variants.id, spree_variants.sku, spree_products.id AS product_id, spree_products.name, spree_line_items.quantity AS sales_items, spree_line_items.price,
        spree_addresses.firstname, spree_addresses.lastname, spree_orders.email, spree_addresses.address1, spree_addresses.address2, spree_states.name AS state_address,
        ARRAY_AGG(DISTINCT(spree_taxons.name)) AS taxons, ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values").
      joins(:variant, :product, order: [:payments, :bill_address]).
      joins("LEFT JOIN spree_states ON spree_addresses.state_id = spree_states.id").
      joins("LEFT JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id LEFT JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id").
      joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
      where(spree_orders: { completed_at: dates }).
      where(spree_payments: { state: 'completed' }).
      group("spree_line_items.id, spree_variants.id, spree_products.id, spree_variants.sku, spree_products.name, spree_line_items.quantity, spree_line_items.price,
        spree_addresses.firstname, spree_addresses.lastname, spree_addresses.address1, spree_addresses.address2, state_address")
  end

  def self.sales_for_month(dates)
    Spree::Order.
      select("TO_CHAR(completed_at, 'MM') AS month, TO_CHAR(completed_at, 'YYYY') AS year,
              spree_orders.number AS order_number,
              spree_orders.email AS client_email,
              spree_orders.item_count AS sales_items,
              spree_orders.total AS total_amount").
      complete.
      where(completed_at: dates)
  end

  def self.total_sales_for_months(dates)
    Spree::Order.
      select("TO_CHAR(completed_at, 'MM') AS month, TO_CHAR(completed_at, 'YYYY') AS year,
              COUNT(spree_orders.id) AS order_quantity,
              SUM(spree_orders.item_count) AS sales_items,
              SUM(spree_orders.total) AS total").
      complete.
      where(completed_at: dates).
      group('year, month')
  end

  def self.variants_details_csv
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << [ Spree.t(:sku), Spree.t(:product_name), Spree.t(:price), Spree.t(:taxons), Spree.t(:brand), Spree.t(:availability) ]

      variants_details.each do |item|
        values =[]

        values << item[:sku]
        values << item[:name]
        values << display_money(item[:price])
        values << item[:taxons].join(', ')
        values << brand(item)
        values << availability(item)
        csv << values
      end
    end
  end

  def self.stock_details_csv
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << [ Spree.t(:sku), Spree.t(:product_name), Spree.t(:price), Spree.t(:brand), Spree.t(:stock_available), Spree.t(:availability), Spree.t(:stock_total) ]

      stock_details.each do |item|
        values =[]

        values << item[:sku]
        values << item[:name]
        values << display_money(item[:price])
        values << brand(item)
        values << item[:stock]
        values << availability(item)
        values << (item[:total] + item[:stock])

        csv << values
      end
    end
  end

  def self.sales_sku_csv(dates)
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << [ Spree.t(:sku), Spree.t(:product_name), Spree.t(:sales_items), Spree.t(:amount) ]

      sales_sku(dates).each do |item|
        values =[]

        values << item[:sku]
        values << item[:name]
        values << item[:sales_items]
        values << display_money(item[:amount])

        csv << values
      end
    end
  end

  def self.sales_for_state_csv(dates)
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << [ Spree.t(:state_address), Spree.t(:city), Spree.t(:order_quantity), Spree.t(:amount) ]

      sales_for_state(dates).each do |item|
        values =[]

        values << item[:state]
        values << item[:city]
        values << item[:order_quantity]
        values << display_money(item[:amount])

        csv << values
      end
    end
  end

  def self.sales_for_product_and_client_csv(dates)
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << [
        Spree.t(:sku), Spree.t(:brand), Spree.t(:taxons), Spree.t(:product_name), Spree.t(:sales_items), Spree.t(:price),
        Spree.t(:client_name), Spree.t(:email), Spree.t(:address), Spree.t(:state_address)
       ]

      sales_for_product_and_client(dates).each do |item|
        values =[]

        values << item[:sku]
        values << brand(item)
        values << item[:taxons].join(', ')
        values << item[:name]
        values << item[:sales_items]
        values << display_money(item[:price])
        values << full_name(item)
        values << item[:email]
        values << full_address(item)
        values << item[:state_address]

        csv << values
      end
    end
  end

  def self.sales_for_month_csv(dates)
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << [ Spree.t(:year), Spree.t(:month), Spree.t(:order_number), Spree.t(:client_email), Spree.t(:sales_items), Spree.t(:total_amount) ]

      sales_for_month(dates).each do |item|
        values =[]

        values << item[:year]
        values << item[:month]
        values << item[:order_number]
        values << item[:client_email]
        values << item[:sales_items]
        values << display_money(item[:total_amount])

        csv << values
      end
    end
  end

  def self.total_sales_for_months_csv(dates)
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << [ Spree.t(:year), Spree.t(:month), Spree.t(:order_quantity), Spree.t(:sales_items), Spree.t(:total_amount) ]

      total_sales_for_months(dates).each do |item|
        values =[]

        values << item[:year]
        values << item[:month]
        values << item[:order_quantity]
        values << item[:sales_items]
        values << display_money(item[:total_amount])

        csv << values
      end
    end
  end

  def self.display_money(amount)
    Spree::Money.new(amount, currency: 'CLP').to_s
  end

  def self.brand(item)
    item[:properties].index('brand') ? (item[:property_values][ item[:properties].index('brand') ]) : ""
  end

  def self.full_name(item)
    [item["firstname"], item["lastname"]].compact.join(' ')
  end

  def self.full_address(item)
    [item["address1"], item["address2"]].compact.join(' ')
  end

  def self.availability(item)
    Spree.t("available.#{!(item[:available_on].nil? || item[:available_on].future?) && item[:deleted_at].nil? && item[:product_deleted_at].nil?}")
  end
end