class Spree::Report::VariantData < Spree::Report
  def self.headers
    [Spree.t(:sku), Spree.t(:taxons), Spree.t(:description), Spree.t(:brand), Spree.t(:availability), Spree.t(:price)]
  end

  def self.compute
    Spree::Variant.
      select("spree_variants.id, spree_products.id AS product_id, spree_products.name as name, spree_variants.sku, spree_prices.amount as price, spree_variants.deleted_at, spree_products.available_on, spree_products.deleted_at AS product_deleted_at,
        ARRAY_AGG(DISTINCT(spree_taxons.name)) AS taxons, ARRAY_AGG(DISTINCT(spree_properties.name)) AS properties, ARRAY_AGG(DISTINCT(spree_product_properties.value)) AS property_values").
      joins(:product, :default_price).
      joins("LEFT JOIN spree_products_taxons ON spree_products_taxons.product_id = spree_products.id LEFT JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id").
      joins("LEFT JOIN spree_product_properties ON spree_product_properties.product_id = spree_products.id LEFT JOIN spree_properties ON spree_properties.id = spree_product_properties.property_id").
      group("spree_variants.id, spree_products.id, spree_products.name, spree_variants.sku, price, spree_variants.deleted_at, spree_products.available_on, product_deleted_at")
  end

  def self.to_csv
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute.each do |item|
        values = []

        values << item[:sku]
        values << item[:taxons].join(', ')
        values << item[:name]
        values << brand(item)
        values << available(item)
        values << item[:price].to_i
        csv << values
      end
    end
  end
end
