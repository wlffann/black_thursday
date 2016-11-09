class Visualization

  def initialize(merchants)
    @merchants = all
  end


  def item_parse(merchant_id)
    temp = find_items_by_merchant_id(merchant_id)
    temp.map { |each| 
                {   :name   => each.name,
                    :stringy => "\n information",
                    :size   => each.unit_price.to_f
                }}
  end

  def invoice_parse(merchant_id)
    temp = find_invoices_by_merchant_id(merchant_id)
    temp.map {|invoice| 
              {     :name         =>  "ID: #{invoice.id}, Status: #{invoice.status}",
                    :stringy      =>  "\n information",
                    :size         =>  invoice.total.to_f,
                    :children     =>  invoice_items_parse(invoice.items)
                }
    }
  end

  def invoice_items_parse(items)
    return {} if items.include?(nil)
    items.map {|item| 
                {   :name         => item.name,
                    :size         => item.unit_price 
                }
    }
  end

  def customer_parse(merchant_id)
    current_merchant = find_by_id(merchant_id)
    temp = current_merchant.customers
    if !temp.include?(nil)
      temp.map {|customer| 
              {     :name             =>  "#{customer.first_name} #{customer.last_name}",
                    :stringy          =>  "\n information",
                    :size             =>  customer.invoices.map {|x| x.total.to_f}.reduce(:+)
                }
    }
    end
  end

  def to_h(merchant_id, total_revenue)
    current_merchant = find_by_id(merchant_id)
    return false if current_merchant.invoices == []
      hashy = {
        :name              => find_by_id(merchant_id).name,
        :stringy           => "\n information",
        :size              => total_revenue,
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

end