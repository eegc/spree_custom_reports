Spree::Variant.class_eval do

  scope :complete_order, -> { joins(:orders).where.not(spree_orders: { completed_at: nil }) }

  def self.sales_sku
    select("spree_variants.id, spree_products.id AS product_id, spree_variants.sku, spree_products.name, spree_variants.variant_name, SUM(spree_line_items.quantity) AS quantity, SUM(spree_line_items.price) AS amount").
    joins(:product).
    where.not(spree_variants: { sku: nil }).
    complete_order.
    group("spree_variants.id, spree_products.id, spree_variants.sku, spree_products.name, spree_variants.variant_name").order("amount DESC")
  end

  def self.sales_sku_csv
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << ["Codigo/SKU", "Nombre", "Items Vendidos", "Monto sin IVA"]

      sales_sku.each do |item|
        values =[]

        values << item[:sku]
        values << (item[:variant_name] || item[:name])
        values << item[:quantity]
        values << Spree::Money.new((item[:amount] / 1.19), currency: 'CLP').to_s

        csv << values
      end
    end
  end

  def self.variant_data
    select("spree_variants.id, spree_products.id AS product_id, spree_variants.sku, spree_variants.deleted_at, spree_products.available_on, spree_products.deleted_at AS product_deleted_at,
      ARRAY_AGG(DISTINCT(spree_taxons.name)) AS taxons, spree_products.description, ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values").
    joins(:product).
    joins("LEFT JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id LEFT JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id").
    joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
    where.not(spree_variants: { sku: nil }).
    group("spree_variants.id, spree_products.id, spree_variants.sku, spree_variants.deleted_at, spree_products.description, spree_products.available_on, spree_products.deleted_at")
  end

  def self.variant_data_csv
    CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << ["Codigo/SKU", "Categoría", "Descripción", "Marca", "Estado"]

      variant_data.each do |item|
        values =[]

        values << item[:sku]
        values << item[:taxons].join(', ')
        values << ActionController::Base.helpers.strip_tags(item[:description])
        values << item[:properties].index('brand') ? item[:property_values][ item[:properties].index('brand') ] : ""
        values << Spree.t("available.#{!(item[:available_on].nil? || item[:available_on].future?) && item[:deleted_at].nil? && item[:product_deleted_at].nil?}")

        csv << values
      end
    end
  end
end
