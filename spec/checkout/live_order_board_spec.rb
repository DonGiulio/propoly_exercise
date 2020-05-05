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

    describe "register order" do
    
      it do
        5.times do |n|
          expect( lob.register(order1) ).to eql(n+1) 
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
              ["user1", 3.5,  306, :SELL],
              ["user2", 1.2,  310, :BUY]
            ]
           }

           let(:expected){
            [
              { type: :SELL, quantity: 3.5, price: 306 },
              { type: :BUY, quantity: 1.2, price: 310 }
            ]
           }

          it{ should match_array expected}

        end
        
        context "overlapping" do
          context "same type" do
            let(:orders) {
              [
                ["user1", 2.0,  310, :BUY],
                ["user2", 1.0,  310, :SELL]
              ]
             }

             let(:expected){
              [
                { type: :BUY, quantity: 1.0, price: 310 }
              ]
             }

            it{ should match_array expected }
          end        
          
          context "changing type" do
            let(:orders) {
              [
                ["user1", 1.0,  310, :BUY],
                ["user2", 2.0,  310, :SELL]
              ]
             }

             let(:expected){
              [
                { type: :SELL, quantity: 1.0, price: 310 }
              ]
             }

            it{ should match_array expected }
          end
          
          context "zeroing" do
            let(:orders) {
              [
                ["user1", 1.0,  310, :BUY],
                ["user2", 1.0,  310, :SELL]
              ]
             }

             let(:expected){
              []
             }

            it{ should match_array expected }
          end
        end
      end
    end
  end
end
