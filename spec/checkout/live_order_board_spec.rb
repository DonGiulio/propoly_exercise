require './app/app.rb'

RSpec.describe LiveOrderBoard do
  
  describe "constructor" do 
    context "correct data" do 
      subject { LiveOrderBoard.new() }
  
      it { should be_truthy }
    end
  end

  context "with LiveOrderBoard" do 
    let!(:lob){ LiveOrderBoard.new() }
    let(:order1) { Order.new(1, 3000, 4.5, :BUY) }
    let(:order2) { Order.new(1, 3000, 4.5, :SELL) }

    describe "register order" do
      it do
        5.times do |n|
          expect( lob.register(order1) ).to eql(n+1) 
        end
        5.times do |n|
          expect( lob.register(order1) ).to eql(n+6) 
        end
      end
    end

    describe "delete order" do
      let(:order_id){ lob.register(order1) }

      it { expect( lob.delete(order_id) ).to be true }
      it { expect( lob.delete(999) ).to be false }
    end

    describe "summary" do

      before do 
        orders.each do |o| 
          lob.register(Order.new(*o))
        end
      end

      subject{ lob.summary }

      context "exercise example" do 
        let(:orders) {
          [
            ["user1", 3.5,  306, :SELL],
            ["user2", 1.2,  310, :SELL],
            ["user3", 1.5,  307, :SELL],
            ["user4", 2.0,  306, :SELL]
          ]
         }

         let(:expected){
          [
            { type: :SELL, quantity: 5.5, price: 306 },
            { type: :SELL, quantity: 1.5, price: 307 },
            { type: :SELL, quantity: 1.2, price: 310 }
          ]
         }
        
        it{ should match_array expected}
      end

      context "with buys" do
        context "non overlapping" do
          let(:orders) {
            [
              ["user1", 3.5,  310, :SELL],
              ["user2", 1.2,  306, :BUY]
            ]
           }

           let(:expected){
            [
              { type: :SELL, quantity: 3.5, price: 310 },
              { type: :BUY, quantity: 1.2, price: 306 }
            ]
           }

          it{ should match_array expected}
        end
        
        context "overlapping" do
          context "partially completed" do
            let(:orders) {
              [
                ["user1", 3.5,  306, :SELL],
                ["user2", 1.2,  310, :BUY]
              ]
             }

             let(:expected){
              [
                {:price=>306, :quantity=>2.3, :type=>:SELL}
              ]
             }

            it{ should match_array expected}
          end
        end

        context "zeroing" do
          let(:orders) {
            [
              ["user1", 3.5,  306, :SELL],
              ["user2", 3.5,  310, :BUY]
            ]
           }

           let(:expected){
            []
           }

          it{ should match_array expected}
        end
      end
    end
  end
end
