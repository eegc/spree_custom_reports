class Spree::Report::SalesForMonth < Spree::Report
  def self.headers
    [Spree.t(:year), Spree.t(:month), Spree.t(:orders), Spree.t(:users), Spree.t(:sales_items), Spree.t(:gross_price)]
  end

  def self.compute(dates)
    Spree::Order.
      select("TO_CHAR(completed_at, 'MM') AS month, TO_CHAR(completed_at, 'YYYY') AS year,
              spree_orders.id,
              spree_orders.number AS number,
              spree_orders.email AS email,
              spree_orders.item_count AS items_quant,
              (spree_orders.item_total + spree_orders.adjustment_total) AS total").
      joins(:payments).
      where(spree_orders: { state: :complete, completed_at: dates }).
      where(spree_payments: { state: :completed })
  end

  def self.to_csv(dates)
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute(dates).each do |item|
        values = []

        values << item[:year]
        values << item[:month]
        values << item[:number]
        values << item[:email]
        values << item[:items_quant]
        values << display_money(item[:total])

        csv << values
      end
    end
  end

end
