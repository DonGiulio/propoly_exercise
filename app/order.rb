class Order

  attr_reader :user_id, :quantity, :price, :type
  attr_accessor :id
  TYPES = [ :BUY, :SELL ]

  def initialize(user_id, quantity, price, type)
    check_params(user_id, quantity, price, type)
    @user_id = user_id
    @quantity = quantity
    @price = price
    @type = type 
  end

  private 
  def check_params(user_id , quantity, price, type)
    raise ArgumentError, "Order type not recognized: #{type} , accepted: #{TYPES} " unless TYPES.include? type
  end


end
