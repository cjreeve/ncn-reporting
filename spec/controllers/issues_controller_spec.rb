require 'rails_helper'

RSpec.describe IssuesController, type: :controller do

  describe "GET #index" do

    context "with view rendering" do

      render_views

      context "no attributes" do

        # TODO: test national, regeional and custom settings
        let(:ranger) { FactoryBot.create(:ranger, issue_filter_mode: "national") }

        before(:each) do
          sign_in ranger
        end

        it "does not raise error" do
          expect{ get :index }.not_to raise_error
        end

        context "one published issue" do
          let(:issue) { FactoryBot.create(:issue, state: 'open') }
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

        let(:ranger) { FactoryBot.create(:ranger) }

        before(:each) do
          sign_in ranger
        end

        let(:issue) { FactoryBot.create(:issue) }
        let(:another_issue) { FactoryBot.create(:issue) }
        before(:each) do
          issue
          another_issue
        end

        it "does not raise error" do
          expect{ get :show, params: { issue_number: issue.issue_number }}.to_not raise_error
        end

        it "finds the issue" do
          get :show, params: { issue_number: issue.issue_number }
          expect( assigns(:issue) ).to eq(issue)
        end

        it "does not find other issue" do
          get :show, params: { issue_number: issue.issue_number }
          expect( assigns(:issue) ).not_to eq(another_issue)
        end
      end


      ####### Test Council Reporting Prompt visibility #######
      context "central area and route 1" do

        context "ranger published issue with label council" do
          let(:group) { FactoryBot.create(:group, name: 'Central') }
          let(:route) { FactoryBot.create(:route, name: 'NCN 1') }
          let(:staff) { FactoryBot.create(:staff) }
          let(:coordinator) { FactoryBot.create(:coordinator) }
          let(:ranger) { FactoryBot.create(:ranger) }
          let(:volunteer) { FactoryBot.create(:volunteer) }
          let(:guest) { FactoryBot.create(:guest) }

          let(:issue) { FactoryBot.create(:issue, label_names: ['council'], user_name: ranger.name, state: 'open') }

          before(:each) do
            coordinator.groups << group
            coordinator.routes << route
            ranger.groups << group
            ranger.routes << route
            volunteer.groups << group
            issue.update_attribute :priority, 2
          end

          context "signed in as staff" do
            before(:each) do
              sign_in staff
              controller.stub(:current_user).and_return(staff)
            end

            it "staff does not see the council 'reporting-prompt'" do
              get :show, params: { issue_number: issue.issue_number }
              expect(response.body).not_to have_css('div.reporting-prompt')
            end
          end

          context "signed in as coordinator" do
            before(:each) do
              sign_in coordinator
              controller.stub(:current_user).and_return(coordinator)
            end

            it "coordinator sees the council 'reporting-prompt'" do
              get :show, params: { issue_number: issue.issue_number }
              expect(response.body).to have_css('div.reporting-prompt')
            end
          end

          if Rails.application.config.enable_issue_reporting_prompt
            context "signed in as ranger" do
              before(:each) do
                sign_in ranger
                controller.stub(:current_user).and_return(ranger)
              end

              it "ranger sees the council 'reporting-prompt'" do
                get :show, params: { issue_number: issue.issue_number }
                expect(response.body).to have_css('div.reporting-prompt')
              end
            end

            context "signed in as volunteer" do
              before(:each) do
                sign_in volunteer
                controller.stub(:current_user).and_return(volunteer)
              end

              it "volunteer does not see the council 'reporting-prompt'" do
                get :show, params: { issue_number: issue.issue_number }
                expect(response.body).not_to have_css('div.reporting-prompt')
              end
            end

            context "signed in as guest" do
              before(:each) do
                sign_in guest
                controller.stub(:current_user).and_return(guest)
              end

              it "guest does not see the council 'reporting-prompt'" do
                get :show, params: { issue_number: issue.issue_number }
                expect(response.body).not_to have_css('div.reporting-prompt')
              end
            end
          end
        end
      end

      if Rails.application.config.enable_issue_reporting_prompt
        context "volunteer published issue with label council" do
          let(:group) { Group.find_by_name('Central') || FactoryBot.create(:group, name: 'Central') }
          let(:route) { Route.find_by_name('NCN 1') || FactoryBot.create(:route, name: 'NCN 1') }

          let(:ranger) { FactoryBot.create(:ranger) }
          let(:volunteer) { FactoryBot.create(:volunteer) }

          let(:issue) { FactoryBot.create(:issue, label_names: ['council'], user_name: volunteer.name, state: 'open') }

          let(:administrative_area) { issue.administrative_area }

          before(:each) do
            ranger.administrative_areas << administrative_area
            ranger.groups << group
            ranger.routes << route
            volunteer.groups << group
            issue.update_attribute :priority, 2
          end

          context "signed in as ranger" do
            before(:each) do
              sign_in ranger
              controller.stub(:current_user).and_return(ranger)
            end

            it "ranger sees the council 'reporting-prompt'" do
              get :show, params: { issue_number: issue.issue_number }
              expect(response.body).to have_css('div.reporting-prompt')
            end
          end

          context "signed in as volunteer" do
            before(:each) do
              sign_in volunteer
              controller.stub(:current_user).and_return(volunteer)
            end

            it "volunteer sees the council 'reporting-prompt'" do
              get :show, params: { issue_number: issue.issue_number }
              expect(response.body).to have_css('div.reporting-prompt')
            end
          end
        end

        context "volunteer submitted issue with label council" do
          let(:group) { Group.find_by_name('Central') || FactoryBot.create(:group, name: 'Central') }
          let(:route) { Route.find_by_name('NCN 1') || FactoryBot.create(:route, name: 'NCN 1') }
          let(:ranger) { FactoryBot.create(:ranger) }
          let(:volunteer) { FactoryBot.create(:volunteer) }

          let(:issue) { FactoryBot.create(:issue, label_names: ['council'], user_name: volunteer.name, state: 'open', priority: 2) }

          let(:administrative_area) { issue.administrative_area }

          before(:each) do
            ranger.administrative_areas << administrative_area
            ranger.groups << group
            ranger.routes << route
            volunteer.groups << group
            issue.update_attribute :priority, 2
          end

          context "signed in as ranger" do
            before(:each) do
              sign_in ranger
              controller.stub(:current_user).and_return(ranger)
            end

            it "ranger sees the council 'reporting-prompt'" do
              get :show, params: { issue_number: issue.issue_number }
              expect(response.body).to have_css('div.reporting-prompt')
            end
          end

          context "signed in as volunteer" do
            before(:each) do
              sign_in volunteer
              controller.stub(:current_user).and_return(volunteer)
            end

            it "volunteer sees the council 'reporting-prompt'" do
              get :show, params: { issue_number: issue.issue_number }
              expect(response.body).to have_css('div.reporting-prompt')
            end
          end
        end
      end
    end
  end
end
