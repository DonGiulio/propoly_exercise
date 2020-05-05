require "byebug" 
class LiveOrderBoard


  def initialize()
    @order_board = []  
  end

  def register(order)
    order.id= @order_board.size + 1
    @order_board << order
    @order_board.size
  end

  def delete(order_id)
    old_size = @order_board.size
    @order_board.reject!{|o| o.id == order_id }
    old_size == @order_board.size + 1 ? true : false
  end

  def summary()
    sorted = sort_orders
    rows = all_rows(sorted)
    compact_rows(rows)
  end

  private

  def sort_orders()
    @order_board.sort_by(&:price).reverse
  end

  def all_rows(sorted)
    full_results = sorted.map do |order| 
      {
        type: order.type, 
        quantity: order.quantity, 
        price: order.price
      }
    end
  end

  def compact_rows(rows)
    rows.each_with_object([]) do |row, result|
      result << row && next if result.last.nil?

      if result.last[:price] != row[:price]
        result << row
      else
        last = result.pop
        new_row = update_row(last, row)
        result << new_row unless new_row.nil?
      end
    end
  end

  def update_row(cur_row, row)
    if(cur_row[:type] == row[:type])
      return {
        type: cur_row[:type],
        quantity: cur_row[:quantity] + row[:quantity], 
        price: cur_row[:price]
      }
    else
      new_qty = cur_row[:quantity] - row[:quantity]
      return nil if new_qty == 0.0
      type = new_qty > 0 ? cur_row[:type] : cur_row[:type] == :SELL ? :BUY : :SELL

      return {
        type: type, 
        quantity: new_qty.abs,
        price: cur_row[:price]
      }
    end
  end
end
