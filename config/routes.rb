Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reports, :only => [] do
      collection do
        get  :variants_details
        post :variants_details
        get  :stock_details
        post :stock_details
        get  :sales_sku
        post :sales_sku
        get  :sales_for_state
        post :sales_for_state
        get  :sales_for_product_and_client
        post :sales_for_product_and_client
        get :sales_for_month
        post :sales_for_month
        get :total_sales_for_months
        post :total_sales_for_months
        get :sales_for_promotion
        post :sales_for_promotion

        get :sales_for_client
        post :sales_for_client
        get :sales_and_stock
        post :sales_and_stock
        get  :variants_data
        post :variants_data
        # get :sales_click_go
        # post :sales_click_go
      end
    end
  end
end
