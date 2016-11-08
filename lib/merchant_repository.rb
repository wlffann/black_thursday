require 'csv'
require_relative 'merchant'
require_relative 'parser'

class MerchantRepository
  include Parser
  attr_reader :all,
              :parent

  def initialize(file_path, parent)
    @all    = create_merchants(file_path)
    @parent = parent
  end

  def create_merchants(file_path)
    data_rows = parse_merchants_csv(file_path)
    data_rows.map { |row| Merchant.new(row, self) }
  end

  def find_by_id(desired_id)
    all.find { |m| m.id == desired_id }
  end

  def find_by_name(desired_name)
    all.find { |m| m.name.downcase == desired_name.downcase }
  end

  def find_all_by_name(desired_name_frag)
    all.find_all { |m| m.name.downcase.include?(desired_name_frag.downcase) }
  end

  def find_items_by_merchant_id(id)
    parent.find_items_by_merchant_id(id)
  end

  def merchant_item_count
    all.map {|m| m.items.count }
  end

  def find_invoices_by_merchant_id(id)
    parent.find_invoices_by_merchant_id(id)
  end

  def find_customer_by_customer_id(customer_id)
    parent.find_customer_by_id(customer_id)
  end

  def item_parse(merchant_id)
    temp = find_items_by_merchant_id(merchant_id)
    temp.map { |each| 
                {   :name   => each.name,
                    :id     => each.id,
                    :price  => each.unit_price.to_f,
                    :desc   => each.description[0..25],
                    :size   => each.unit_price.to_f
                }}
  end

  def invoice_parse(merchant_id)
    temp = find_invoices_by_merchant_id(merchant_id)
    temp.map {|each| 
      temp_customer = find_customer_by_customer_id(each.customer_id)
              {     :id           =>  each.id,
                    :status       =>  each.status,
                    :customer     =>  "#{temp_customer.first_name} #{temp_customer.last_name}",
                    :size         =>  50
                }
    }
  end

  def customer_parse(merchant_id)
    temp = find_invoices_by_merchant_id(merchant_id)
      temp.map {|each| 
      temp_customer = find_customer_by_customer_id(each.customer_id)
              {     :id           =>  temp_customer.id,
                    :customer     =>  "#{temp_customer.first_name} #{temp_customer.last_name}",
                    :size         => 50
                }
    }
  end

  def to_h(merchant_id)
      hashy = {
        :name           => find_by_id(merchant_id).name,
        :id             => find_by_id(merchant_id).id,
        :registration   => "#{find_by_id(merchant_id).created_at.month}, #{find_by_id(merchant_id).created_at.year}",
        :size           => "merchant.revenue",
        :avg_item_price => 0,
        :children       => [
          { :name     => "items",
            :size     => find_items_by_merchant_id(merchant_id).count,
            :children => item_parse(merchant_id)
          },
          { :name     => "invoices",
            :size     => find_invoices_by_merchant_id(merchant_id).count,
            :children => invoice_parse(merchant_id)
          },
          { :name     => "customers",
            :size     => "customers.revenue_count",
            :children => customer_parse(merchant_id)
          }
        ]
      }
    hashy
  end

  def inspect
  end
end