require 'spec_helper'

module Plutus
  describe Account do
    let(:account) { FactoryGirl.build(:account) }
    subject { account }
    
    it { should_not be_valid }  # must construct a child type instead

    describe "when using a child type" do
      let(:account) { FactoryGirl.create(:account, type: "Finance::Asset") }
      it { should be_valid }
      
      it "should be unique per name" do
        conflict = FactoryGirl.build(:account, name: account.name, type: account.type)
        conflict.should_not be_valid
        conflict.errors[:name].should == ["has already been taken"]
      end
    end
    
    it { should_not respond_to(:balance) }
    
    describe ".trial_balance" do
      subject { Account.trial_balance }
      it { should be_kind_of BigDecimal }
      
      context "when given no transactions" do
        it { should == 0 }
      end
      
      context "when given correct transactions" do
        before {
          # credit accounts
          liability = FactoryGirl.create(:liability)
          equity = FactoryGirl.create(:equity)
          revenue = FactoryGirl.create(:revenue)
          contra_asset = FactoryGirl.create(:asset, :contra => true)
          contra_expense = FactoryGirl.create(:expense, :contra => true)
          # credit amounts
          ca1 = FactoryGirl.build(:credit_amount, :account => liability, :amount => 100000)
          ca2 = FactoryGirl.build(:credit_amount, :account => equity, :amount => 1000)
          ca3 = FactoryGirl.build(:credit_amount, :account => revenue, :amount => 40404)
          ca4 = FactoryGirl.build(:credit_amount, :account => contra_asset, :amount => 2)
          ca5 = FactoryGirl.build(:credit_amount, :account => contra_expense, :amount => 333)

          # debit accounts
          asset = FactoryGirl.create(:asset)
          expense = FactoryGirl.create(:expense)
          contra_liability = FactoryGirl.create(:liability, :contra => true)
          contra_equity = FactoryGirl.create(:equity, :contra => true)
          contra_revenue = FactoryGirl.create(:revenue, :contra => true)
          # debit amounts
          da1 = FactoryGirl.build(:debit_amount, :account => asset, :amount => 100000)
          da2 = FactoryGirl.build(:debit_amount, :account => expense, :amount => 1000)
          da3 = FactoryGirl.build(:debit_amount, :account => contra_liability, :amount => 40404)
          da4 = FactoryGirl.build(:debit_amount, :account => contra_equity, :amount => 2)
          da5 = FactoryGirl.build(:debit_amount, :account => contra_revenue, :amount => 333)

          FactoryGirl.create(:transaction, :credit_amounts => [ca1], :debit_amounts => [da1])
          FactoryGirl.create(:transaction, :credit_amounts => [ca2], :debit_amounts => [da2]) 
          FactoryGirl.create(:transaction, :credit_amounts => [ca3], :debit_amounts => [da3])
          FactoryGirl.create(:transaction, :credit_amounts => [ca4], :debit_amounts => [da4])
          FactoryGirl.create(:transaction, :credit_amounts => [ca5], :debit_amounts => [da5])
        }
        
        it { should == 0 }
      end
    end
  end
end
