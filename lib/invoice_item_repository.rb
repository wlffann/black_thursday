require_relative 'invoice_item'
require_relative 'parser'

class InvoiceItemRepository
  include Parser

  attr_reader :all, :parent

  def initialize(file_path, parent)
    @all    = create_invoice_items(file_path)
    @parent = parent
  end

  def create_invoice_items(file_path)
    invoice_item_data = parse_invoice_items_csv(file_path)
    invoice_item_data.map {|row| InvoiceItem.new(row, self)} 
  end

  def find_by_id(desired_id)
    all.find { |invoice_item| invoice_item.id.eql?(desired_id) }
  end

  def find_all_by_item_id(desired_id)
    all.find_all { |invoice_item| invoice_item.item_id.eql?(desired_id) }
  end

  def find_all_by_invoice_id(desired_id)
    all.find_all { |invoice_item| invoice_item.invoice_id.eql?(desired_id) }
  end

end