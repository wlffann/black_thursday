class Customer

  attr_reader :id,
              :first_name,
              :last_name,
              :created_at,
              :updated_at,
              :parent

  def initialize(data, parent)
    @id         = data[:id].to_i
    @first_name = data[:first_name]
    @last_name  = data[:last_name]
    @created_at = Time.parse(data[:created_at])
    @updated_at = Time.parse(data[:updated_at])
    @parent     = parent
  end


  def merchants
    invoices = parent.find_invoices_by_customer_id(id)
    invoices.map { |i| parent.find_merchants_by_merchant_id(i.merchant_id) }
  end

  def invoices
    parent.find_invoices_by_customer_id(id)
  end

end