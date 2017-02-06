Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reports, :only => [] do
      collection do
        get   :sales_sku
        post  :sales_sku
        get   :products_details
        post  :products_details
      end
    end
  end
end
