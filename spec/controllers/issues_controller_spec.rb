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

      context "one published issue" do
        let(:issue) { FactoryGirl.create(:issue, state: 'open') }
        before(:each) { issue }

        it "finds one result" do
          get :index
          expect(assigns(:issues).size).to eq(1)
        end

        it "finds expected issue" do
          get :index
          expect(assigns(:issues).first).to eq(issue)
        end
      end
    end
  end
end
