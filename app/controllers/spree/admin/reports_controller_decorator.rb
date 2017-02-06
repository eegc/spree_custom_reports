Spree::Admin::ReportsController.class_eval do
  before_filter :add_custom_reports, only: :index

  def sales_sku
    respond_to do |format|
      format.html { @item_sales = Spree::Variant.sales_sku.page(params[:page]).per(20) }
      format.csv  { send_data Spree::Variant.sales_sku_csv, filename: "#{Spree.t(:sales_sku).parameterize}-#{Date.today}.csv" }
    end
  end

  def products_details
    respond_to do |format|
      format.html { @items = Spree::Variant.variant_data.page(params[:page]).per(20) }
      format.csv  { send_data Spree::Variant.variant_data_csv, filename: "#{Spree.t(:sales_sku).parameterize}-#{Date.today}.csv" }
    end
  end

  private

  def add_custom_reports
    Spree::Admin::ReportsController.add_available_report!(:sales_sku)
    Spree::Admin::ReportsController.add_available_report!(:products_details)
  end
end
