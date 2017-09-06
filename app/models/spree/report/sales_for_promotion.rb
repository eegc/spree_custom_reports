class Spree::Report::SalesForPromotion < Spree::Report
  def self.headers
    [Spree.t(:campaign_name), Spree.t(:code), Spree.t(:num_orders), Spree.t(:client_name), Spree.t(:email), Spree.t(:date), Spree.t(:hour), Spree.t(:total)]
  end

  def self.compute(dates)
    Spree::Order.
      select("spree_promotions.name, spree_promotions.code, spree_orders.number,
        spree_addresses.firstname, spree_addresses.lastname, spree_orders.email, spree_orders.completed_at, spree_orders.total").
      joins(:promotions).
      joins(:bill_address, :payments).
      where(spree_orders: { state: :complete, completed_at: dates }).
      where(spree_payments: { state: :completed }).
      group("spree_orders.id, spree_promotions.name, spree_promotions.code, spree_orders.number,
            spree_addresses.firstname, spree_addresses.lastname, spree_orders.email,
            spree_orders.completed_at, spree_orders.total").
      order("spree_orders.total DESC")
  end

  def self.to_csv(dates)
    CSV.generate(col_sep: ';') do |csv|
      csv << headers

      compute(dates).each do |item|
        values = []

        values << item[:name]
        values << item[:code]
        values << item[:number]
        values << full_name(item)
        values << item[:email]
        values << item.completed_at.strftime("%d-%m-%Y")
        values << item.completed_at.strftime("%H:%M")
        values << display_money(item[:total])

        csv << values
      end
    end
  end

end