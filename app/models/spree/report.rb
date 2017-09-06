class Spree::Report
  require 'csv'

  def self.compute
    raise 'compute should be implemented in a sub-class of Spree::Report'
  end

  def self.to_csv
    raise 'to_csv should be implemented in a sub-class of Spree::Report'
  end

  def self.headers
    raise 'headers should be implemented in a sub-class of Spree::Report'
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