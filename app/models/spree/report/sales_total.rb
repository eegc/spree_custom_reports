class Spree::Report::SalesTotal < Spree::Report
  def self.headers
    [ Spree.t(:item_total), Spree.t(:discount_total), "#{Spree.t(:total)} ( #{Spree.t(:item_total)} + #{Spree.t(:discount_total)} )", Spree.t(:shipment), "#{Spree.t(:order_total)} (#{Spree.t(:total)} + #{Spree.t(:shipment)})", Spree.t(:state) ]
  end

  def self.compute(dates)
    Spree::Order.
      select("SUM(spree_orders.item_total) AS item_total,
              SUM(spree_orders.adjustment_total) AS adjustment_total,
              SUM(spree_orders.item_total + spree_orders.adjustment_total) AS total,
              SUM(spree_orders.shipment_total) AS shipment_total,
              SUM(total) AS order_total,
              spree_payments.state AS payment_state").
      joins(:payments).
      where(spree_orders: { state: :complete, completed_at: dates }).
      # where(spree_payments: { state: :completed })
      group("spree_payments.state")
      # .order("total DESC")
  end

  def self.to_csv(dates)
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute(dates).each do |item|
        values = []

        values << display_money(item[:item_total])
        values << display_money(item[:adjustment_total])
        values << display_money(item[:total])
        values << display_money(item[:shipment_total])
        values << display_money(item[:order_total])
        values << item[:payment_state]

        csv << values
      end
    end
  end

end
