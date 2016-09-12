require 'rails_helper'

RSpec.describe IssuesController, type: :controller do

  describe "GET #index" do

    context "no attributes" do

      let(:ranger) { FactoryGirl.create(:ranger) }

      before(:each) do
        sign_in ranger
      end

      it "does not raise error" do
        expect{ get :index }.not_to raise_error
      end
    end
  end

end
