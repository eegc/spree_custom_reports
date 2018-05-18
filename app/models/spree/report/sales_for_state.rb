class Spree::Report::SalesForState < Spree::Report
  def self.headers
    [Spree.t(:state_address), Spree.t(:city), Spree.t(:quantity), Spree.t(:gross_price)]
  end

  def self.compute(dates)
    # UPPER(spree_counties.name),
    Spree::Order.
      select("UPPER(spree_states.name) AS state,
              UPPER(TRIM(spree_addresses.city)) AS city,
              COUNT(spree_orders.id) AS orders_quant,
              SUM(spree_orders.item_count) AS items_quant,
              SUM(spree_orders.item_total + spree_orders.adjustment_total) AS total").
      joins(:payments, :bill_address).
      joins("LEFT JOIN spree_states ON spree_addresses.state_id = spree_states.id").
      where(spree_orders: { state: :complete, completed_at: dates }).
      # where(spree_payments: { state: :completed }).
      group("UPPER(spree_states.name), spree_states.id, UPPER(TRIM(spree_addresses.city))").
      order("spree_states.id")
  end

  def self.to_csv(dates)
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute(dates).each do |item|
        values = []

        values << item[:state]
        values << item[:city]
        values << item[:orders_quant]
        values << gross_price(item[:total])

        csv << values
      end
    end
  end

end
