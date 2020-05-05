require './app/app.rb'

RSpec.describe Order do
  
  describe "constructor" do 
    context "correct data" do
      context "BUY" do 
        subject { Order.new(1, 4000, 3500, :BUY) }
    
        it { expect(subject).to be_truthy }
        it {  expect(subject.user_id) == 1 }
        it {  expect(subject.quantity) == 4000 }
        it {  expect(subject.price) == 3500 }
        it {  expect(subject.type) == :BUY }
      end
      context "SELL" do 
        subject { Order.new(1, 4000, 3500, :SELL) }

        it {  expect(subject.type) == :SELL }
      end
    end

  end

end
