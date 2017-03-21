Spree::Admin::ReportsController.class_eval do
  before_action :add_custom_reports, only: :index
  before_action :set_dates, only: [ :sales_sku, :sales_for_state, :sales_for_product_and_client, :sales_for_month, :total_sales_for_months ]

  def variants_details
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report.variants_details.to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.variants_details_csv, filename: "#{Spree.t(:variants_details).parameterize}-#{Date.today}.csv" }
    end
  end

  def stock_details
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report.stock_details.to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.stock_details_csv, filename: "#{Spree.t(:stock_details).parameterize}-#{Date.today}.csv" }
    end
  end

  def sales_sku
    respond_to do |format|
      format.html { @item_sales = Kaminari.paginate_array(Spree::Report.sales_sku(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.sales_sku_csv(@dates), filename: "#{Spree.t(:sales_sku).parameterize}-#{Date.today}.csv" }
    end
  end

  def sales_for_state
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report.sales_for_state(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.sales_for_state_csv(@dates), filename: "#{Spree.t(:sales_for_state).parameterize}-#{Date.today}.csv" }
    end
  end

  def sales_for_product_and_client
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report.sales_for_product_and_client(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.sales_for_product_and_client_csv(@dates), filename: "#{Spree.t(:sales_for_product_and_client).parameterize}-#{Date.today}.csv" }
    end
  end

  def sales_for_month
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report.sales_for_month(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.sales_for_month_csv(@dates), filename: "#{Spree.t(:sales_for_month).parameterize}-#{Date.today}.csv" }
    end
  end

  def total_sales_for_months
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report.total_sales_for_months(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.total_sales_for_months_csv(@dates), filename: "#{Spree.t(:total_sales_for_months).parameterize}-#{Date.today}.csv" }
    end
  end

  def sales_for_promotion
    respond_to do |format|
      format.html { @items = Kaminari.paginate_array(Spree::Report.sales_for_promotion(@dates).to_a).page(params[:page]).per(20) }
      format.csv  { send_data Spree::Report.sales_for_promotion_csv(@dates), filename: "#{Spree.t(:sales_for_promotion).parameterize}-#{Date.today}.csv" }
    end
  end

  private

  def add_custom_reports
    Spree::Admin::ReportsController.add_available_report!(:variants_details)
    Spree::Admin::ReportsController.add_available_report!(:stock_details)
    Spree::Admin::ReportsController.add_available_report!(:sales_sku)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_state)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_product_and_client)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_month)
    Spree::Admin::ReportsController.add_available_report!(:total_sales_for_months)
    Spree::Admin::ReportsController.add_available_report!(:sales_for_promotion)
  end

  def set_dates
    if params[:completed_at_gt].blank?
      params[:completed_at_gt] = Time.zone.now.beginning_of_month
    else
      params[:completed_at_gt] = Time.zone.parse(params[:completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
    end

    if params[:completed_at_lt].blank?
      params[:completed_at_lt] = Time.zone.now.end_of_month
    else
      params[:completed_at_lt] = Time.zone.parse(params[:completed_at_lt]).beginning_of_day rescue Time.zone.now.end_of_month
    end

    gt = params[:completed_at_gt]
    lt = params[:completed_at_lt]

    @dates = (gt..lt)
  end
end