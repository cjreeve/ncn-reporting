require 'rails_helper'

RSpec.describe IssuesController, type: :controller do

  describe "GET #index" do

    context "with view rendering" do

      render_views

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
            expect( assigns(:issues).size ).to eq(1)
          end

          it "finds expected issue" do
            get :index
            expect( assigns(:issues).first ).to eq(issue)
          end
        end
      end
    end
  end

  describe 'GET show' do

    describe "with view rendering" do

      render_views

      context "signed in as ranger" do

        let(:ranger) { FactoryGirl.create(:ranger) }

        before(:each) do
          sign_in ranger
        end

        let(:issue) { FactoryGirl.create(:issue) }
        let(:another_issue) { FactoryGirl.create(:issue) }
        before(:each) do
          issue
          another_issue
        end

        it "does not raise error" do
          expect{ get :show, issue_number: issue.issue_number }.to_not raise_error
        end

        it "finds the issue" do
          get :show, issue_number: issue.issue_number
          expect( assigns(:issue) ).to eq(issue)
        end

        it "does not find other issue" do
          get :show, issue_number: issue.issue_number
          expect( assigns(:issue) ).not_to eq(another_issue)
        end
      end

      context "central area and route 1" do

        context "ranger for area and route" do

          let(:ranger) { FactoryGirl.create(:ranger) }

          before(:each) do
            sign_in ranger
            controller.stub(:current_user).and_return(ranger)
          end

          context "published issue with label council" do
            let(:issue) { FactoryGirl.create(:issue, label_names: ['council'], user_name: ranger.name) }

            it "shows the class 'reporting-prompt'" do
              get :show, issue_number: issue.issue_number
              expect(response.body).to have_css('div.reporting-prompt')
            end
          end
        end
      end
    end
  end
end
