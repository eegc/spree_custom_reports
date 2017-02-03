Spree::Variant.class_eval do

  scope :complete_order, -> { joins(:orders).where.not(spree_orders: { completed_at: nil }) }

  def self.sales_sku
    select("spree_variants.id, spree_products.id AS product_id, spree_variants.sku, spree_products.name, spree_variants.variant_name, SUM(spree_line_items.quantity) AS quantity, SUM(spree_line_items.price) AS amount").
    joins(:product).
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
end
