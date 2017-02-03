Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reports, :only => [] do
      collection do
        get   :sales_sku
        post  :sales_sku
      end
    end
  end
end
