require_relative 'merchant_repository'

class Visualization

  attr_reader :merchants, :parent

  def initialize(merchants, parent)
    @merchants = merchants
    @parent = parent
  end

  def generate_merchant_json
    thing = merchants.all.map do |m| 
      total_revenue = parent.revenue_by_merchant(m.id).to_f
      to_h(m.id, total_revenue) ? stuff = to_h(m.id, total_revenue) : ''
    end
    outer_thing = {:name=> "merchants", :children => thing}
    File.open("./lib/json_for_real.json",'w') do |f|
      f.write(JSON.pretty_generate(outer_thing))
    end
  end

  def to_h(merchant_id, total_revenue)
    current_merchant = merchants.find_by_id(merchant_id)
    return false if current_merchant.invoices == []
      hashy = {
        :name              => merchants.find_by_id(merchant_id).name,
        :stringy           => "\n information",
        :size              => total_revenue,
        :children       => [
          { :name     => "items",
            :size     => merchants.find_items_by_merchant_id(merchant_id).count,
            :children => item_parse(merchant_id)
          },
          { :name     => "invoices",
            :size     => merchants.find_invoices_by_merchant_id(merchant_id).count,
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


  def item_parse(merchant_id)
    temp = merchants.find_items_by_merchant_id(merchant_id)
    temp.map { |each| 
                {   :name   => each.name,
                    :stringy => "\n information",
                    :size   => each.unit_price.to_f
                }}
  end

  def invoice_parse(merchant_id)
    temp = merchants.find_invoices_by_merchant_id(merchant_id)
    temp.map {|invoice| 
                  var = invoice.total.to_f if invoice.total.to_f != 0
                  var = 50 if invoice.total.to_f == 0
              {     :name         =>  "ID: #{invoice.id} Status: #{invoice.status}",
                    :stringy      =>  "\n information",
                    :size         =>  var,
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
    current_merchant = merchants.find_by_id(merchant_id)
    temp = current_merchant.customers
    if !temp.include?(nil)
      temp.map {|customer| 
              {     :name             =>  "#{customer.first_name} #{customer.last_name}",
                    :stringy          =>  "\n information",
                    :size             =>  customer.invoices.map {|x| x.total.to_f}.reduce(50,:+)
                }
    }
    end
  end

end