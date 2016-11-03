class Invoice

  attr_reader :id,
              :customer_id,
              :merchant_id,
              :status,
              :created_at,
              :updated_at,
              :parent

  def initialize(data, parent)
    @id           = data[:id].to_i
    @customer_id  = data[:customer_id].to_i
    @merchant_id  = data[:merchant_id].to_i
    @status       = data[:status].to_sym
    @created_at   = data[:created_at]
    @updated_at   = data[:updated_at]
    @parent       = parent
  end

  def merchant 
    parent.find_merchant_by_id(merchant_id)
  end

  def items
    invoice_items = parent.find_invoice_items_by_invoice_id(id)
    invoice_items.map { |invoice_items| parent.find_item_by_item_id(invoice_items.id)}
  end

  def transactions
    parent.find_transactions_by_invoice_id(id)
  end

  def customer
    parent.find_customer_by_id(customer_id)
  end
end