module Spree
  module Admin
    module ReportsHelper

      def product_available?(item)
        (!(item[:available_on].nil? || item[:available_on].future?) && item[:deleted_at].nil? && item[:product_deleted_at].nil?)
      end

      def brand(item)
        item[:properties].index('brand') ? item[:property_values][ item[:properties].index('brand') ] : ""
      end

    end
  end
end