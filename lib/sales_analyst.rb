require 'bigdecimal'
require 'pry'
require 'json'
require_relative 'statistics'
require_relative 'date_accessor'
require_relative 'items_count_analyst'
require_relative 'items_price_analyst'
require_relative 'invoice_count_analyst'
require_relative 'merchants_revenue_analyst'

class SalesAnalyst
  include Statistics
  extend Forwardable

  attr_reader :engine

  def initialize(engine)
    @engine = engine
    @items_count_analyst = ItemsCountAnalyst.new(engine)
    @items_price_analyst = ItemsPriceAnalyst.new(engine)
    @invoice_count_analyst = InvoiceCountAnalyst.new(engine)
    @merchants_revenue_analyst = MerchantsRevenueAnalyst.new(engine)
  end

  def_delegators :@items_count_analyst,
                    :average_items_per_merchant,
                    :average_items_per_merchant_standard_deviation,
                    :merchants_with_high_item_count,
                    :merchants_with_only_one_item,
                    :merchants_with_only_one_item_registered_in_month

  def_delegators :@items_price_analyst,
                    :average_item_price_for_merchant,
                    :average_average_price_per_merchant,
                    :golden_items

  def_delegators :@invoice_count_analyst,
                    :merchant_invoice_count,
                    :average_invoices_per_merchant,
                    :average_invoices_per_merchant_standard_deviation,
                    :top_merchants_by_invoice_count,
                    :bottom_merchants_by_invoice_count,
                    :top_days_by_invoice_count,
                    :invoice_status,
                    :merchants_with_pending_invoices

  def_delegators :@merchants_revenue_analyst,
                    :total_revenue_by_date,
                    :top_revenue_earners,
                    :merchants_ranked_by_revenue,
                    :revenue_by_merchant,
                    :best_item_for_merchant,
                    :most_sold_item_for_merchant

  def generate_merchant_json
    thing = engine.merchants.all.map do |m| 
      total_revenue = revenue_by_merchant(m.id).to_f
      engine.merchants.to_h(m.id, total_revenue) ? stuff = engine.merchants.to_h(m.id, total_revenue) : ''
        # stuff[:size]            = revenue_by_merchant(m.id).to_f 
        # stuff[:avg_item_price]  = average_item_price_for_merchant(m.id).to_f
    end
    outer_thing = {:name=> "merchants", :children => thing}
    File.open("./lib/json_for_real.json",'w') do |f|
      f.write(JSON.pretty_generate(outer_thing))
    end
  end

end