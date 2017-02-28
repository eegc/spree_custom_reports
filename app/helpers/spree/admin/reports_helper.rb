module Spree
  module Admin
    module ReportsHelper

      def availability?(item)
        Spree::Report.availability(item)
      end

      def brand(item)
        Spree::Report.brand(item)
      end

      def display_money(amount)
        Spree::Report.display_money(amount)
      end

      def full_name(item)
        Spree::Report.full_name(item)
      end

      def full_address(item)
        Spree::Report.full_address(item)
      end

      def dates
        {
          completed_at_gt: params[:completed_at_gt],
          completed_at_lt: params[:completed_at_lt]
        }
      end

      def csv_button
        button_tag(
          content_tag(:span, '', class: 'icon icon-download-alt') + ' CSV',
          :value => 'csv',
          :name => 'format',
          class: "btn btn-success"
        )
      end
    end
  end
end
