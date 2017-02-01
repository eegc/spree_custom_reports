Spree::Admin::ReportsController.class_eval do
  before_filter :add_sales_sku, only: :index

  def sales_sku
    @item_sales = Spree::Variant.sales_sku.page(params[:page]).per(20)
  end

  private

  def add_sales_sku
    Spree::Admin::ReportsController.add_available_report!(:sales_sku)
  end
end
