Spree::Admin::ReportsController.class_eval do
  before_action :add_custom_reports, only: :index
  before_action :set_dates, only: [:sales_total, :sales_sku, :sales_click_go, :sales_for_state, :sales_for_client, :sales_and_stock, :sales_for_month, :sales_for_promotion]

  def sales_total
    respond_to do |format|
      format.html { @items = Spree::Report::SalesTotal.compute(@dates) }
      format.csv  { send_file(report_klass: Spree::Report::SalesTotal, dates: @dates) }
    end

  end

  def sales_sku
    respond_to do |format|
      format.html do
        @items = Spree::Report::SalesSku.compute(@dates)

        @totals = {
          total_amount: @items.inject(0){ |sum,i| sum + i[:total] },
          items: @items.inject(0){ |sum,i| sum + i[:items_quant] },
          orders: @items.flat_map{ |i| i.order_ids }.uniq.count
        }

        @items = Kaminari.paginate_array(@items.to_a).page(params[:page]).per(20)
      end

      format.csv  { send_file(report_klass: Spree::Report::SalesSku, dates: @dates) }
    end
  end

  def sales_for_month
    respond_to do |format|
      format.html do
        @items = Spree::Report::SalesForMonth.compute(@dates)

        @totals = {
          total_amount: @items.inject(0){ |sum,i| sum + i[:total] },
          items: @items.inject(0){ |sum,i| sum + i[:items_quant] },
          orders: @items.length
        }

        @items = Kaminari.paginate_array(@items.to_a).page(params[:page]).per(20)
      end

      format.csv  { send_file(report_klass: Spree::Report::SalesForMonth, dates: @dates) }
    end
  end

  # def sales_click_go
  #   respond_to do |format|
  #     format.html do
  #       @items = Spree::Report::SalesClickGo.compute(@dates)

  #       @totals = {
  #         total_amount: @items.inject(0){ |sum,i| sum + i[:total] },
  #         items: @items.inject(0){ |sum,i| sum + i[:quantity] },
  #         orders: @items.flat_map{ |i| i.number }.uniq.count
  #       }

  #       @items = Kaminari.paginate_array(@items.to_a).page(params[:page]).per(20)
  #     end

  #     format.csv  { send_file(report_klass: Spree::Report::SalesClickGo, dates: @dates) }
  #   end
  # end

  def sales_for_state
    respond_to do |format|
      format.html do
        @items = Spree::Report::SalesForState.compute(@dates)

        @totals = {
          total_amount: @items.inject(0){ |sum,i| sum + i[:total] },
          items: @items.inject(0){ |sum,i| sum + i[:items_quant] },
          orders: @items.inject(0){ |sum,i| sum + i[:orders_quant] }
        }

        @items = Kaminari.paginate_array(@items.to_a).page(params[:page]).per(20)
      end

      format.csv  { send_file(report_klass: Spree::Report::SalesForState, dates: @dates) }
    end
  end

  def sales_for_client
    respond_to do |format|

      format.html do
        @items = Spree::Report::SalesForClient.compute(@dates)

        @totals = {
          total_amount: @items.inject(0){ |sum,i| sum + (i[:total])},
          items: @items.inject(0){ |sum,i| sum + i[:quantity] },
          orders: @items.flat_map{ |i| i.order_ids }.uniq.count
        }

        @items = Kaminari.paginate_array(@items.to_a).page(params[:page]).per(20)
      end

      format.csv  { send_file(report_klass: Spree::Report::SalesForClient, dates: @dates) }
    end
  end

  def sales_and_stock
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report::SalesAndStock.compute(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_file(report_klass: Spree::Report::SalesAndStock, dates: @dates) }
    end
  end


  def sales_for_promotion
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report::SalesForPromotion.compute(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_file(report_klass: Spree::Report::SalesForPromotion, dates: @dates) }
    end
  end

  def variants_data
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report::VariantData.compute.to_a).page(params[:page]).per(20) }
      format.csv  { send_file(report_klass: Spree::Report::VariantData, dates: nil) }
    end
  end

  def stock_details
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report::StockDetail.compute.to_a).page(params[:page]).per(20) }
      format.csv  { send_file(report_klass: Spree::Report::StockDetail, dates: nil) }
    end
  end

  private

  def add_custom_reports
    Spree::Admin::ReportsController.add_available_report!(:sales_sku)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_month)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_state)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_client)
    Spree::Admin::ReportsController.add_available_report!(:sales_and_stock)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_promotion)
    Spree::Admin::ReportsController.add_available_report!(:variants_data)
    Spree::Admin::ReportsController.add_available_report!(:stock_details)
    # Spree::Admin::ReportsController.add_available_report!(:sales_click_go)
  end

  def set_dates
    if params[:completed_at_gt].blank?
      params[:completed_at_gt] = Time.zone.now.beginning_of_month
    else
      params[:completed_at_gt] = begin
                                   Time.zone.parse(params[:completed_at_gt]).beginning_of_day
                                 rescue
                                   Time.zone.now.beginning_of_month
                                 end
    end

    if params[:completed_at_lt].blank?
      params[:completed_at_lt] = Time.zone.now.end_of_month
    else
      params[:completed_at_lt] = begin
                                   Time.zone.parse(params[:completed_at_lt]).end_of_day
                                 rescue
                                   Time.zone.now.end_of_month
                                 end
    end

    gt = params[:completed_at_gt]
    lt = params[:completed_at_lt]

    @dates = (gt..lt)
  end

  private

  def send_file(report_klass:, dates:)
    data = dates.nil? ? report_klass.send('to_csv') : report_klass.send('to_csv', @dates)

    send_data(
      Iconv.conv('iso-8859-1//TRANSLIT//IGNORE', 'utf-8', data),
      type: 'text/csv; charset=iso-8859-1; header=present',
      filename: "#{Spree.t(action).parameterize}-#{Date.today}.csv"
      )
  end
end
