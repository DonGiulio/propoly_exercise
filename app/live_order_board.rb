class LiveOrderBoard

  def initialize()
    @next_id = 1
    @order_board_buy = []  
    @order_board_sell = []  
    @completed_orders = []
  end

  def register(order)
    if order.type == :SELL
      my_board = @order_board_sell
      other_board = @order_board_buy
      compare = lambda {|x, y| x >= y }
    else
      my_board = @order_board_buy
      other_board = @order_board_sell
      compare = lambda {|x, y| x <= y }
    end
    enqueue_order(order, my_board)

    last_opposite_order = other_board.last
    return order.id if last_opposite_order.nil?

    if compare.call(last_opposite_order.price, order.price)
      execute(order, last_opposite_order)
      register(order) unless order.status == :complete
    end

    return order.id
  end

  def delete(order_id)
    old_size = @order_board_buy.size + @order_board_sell.size
    @order_board_buy.reject!{|o| o.id == order_id }
    @order_board_sell.reject!{|o| o.id == order_id }
    new_size = @order_board_buy.size + @order_board_sell.size
    return old_size == new_size + 1 ? true : false
  end

  def summary()
    sell_rows = all_rows(@order_board_sell) 
    buy_rows = all_rows(@order_board_buy)
    compact_rows(sell_rows) + compact_rows(buy_rows)
  end

  private

  def enqueue_order(order, board)
    board << order
    sort_orders(board)
    order.id = @next_id 
    @next_id += 1
    order.status = :queued
  end

  def execute(order, last_order)
    if last_order.quantity == order.quantity
      execute_order(last_order)
      execute_order(order)
    elsif last_order.quantity > order.quantity
      execute_order(order)
      partial_execute_order(last_order, order.quantity)
    else
      execute_order(last_order)
      partial_execute_order(order, last_order.quantity)
    end
  end

  def partial_execute_order(order, quantity)
    order.quantity -= quantity
    order.status = :partially_completed
  end

  def execute_order(order)
    order.status = :complete
    @completed_orders << order
    get_board(order).delete(order)
  end

  def get_board(order)
    order.type == :SELL ? @order_board_sell : @order_board_buy
  end

  def sort_orders(board)
    board.sort_by!(&:price).reverse
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
