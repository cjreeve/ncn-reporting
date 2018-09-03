require 'rails_helper'

describe Issue do

  let(:guest) { FactoryGirl.create(:guest) }
  let(:volunteer) { FactoryGirl.create(:volunteer) }
  let(:ranger) { FactoryGirl.create(:ranger) }
  let(:coordinator) { FactoryGirl.create(:coordinator) }
  let(:staff) { FactoryGirl.create(:staff) }
  let(:central_group) { Group.find_by_name('Central') || FactoryGirl.create(:group, name: 'Central') }
  let(:islington_area) { AdministrativeArea.find_by_short_name("Islington") || FactoryGirl.create(:administrative_area) }
  let(:tower_hamlets_area) { AdministrativeArea.find_by_short_name("Tower Hamlets") || FactoryGirl.create(:administrative_area, name: "Tower Hamlets", short_name: "Tower Hamlets") }
  let(:route_ncn1) { Route.find_by_name('NCN 1') || FactoryGirl.create(:route, name: 'NCN 1') }

  describe '#staff_section_managers' do
    context "staff and ranger users assigned to London Central but no area or route" do
      before(:each) do
        staff.groups << central_group
        ranger.groups << central_group
      end
      context "issue for central & islington & NCN 1" do
        let(:issue) { FactoryGirl.create(:issue) }
        before(:each) do
          issue.update_attribute :administrative_area, islington_area
        end

        it "returns staff user" do
            issue.staff_section_managers.should eq([staff])
        end
      end
    end
  end

  describe '#route_section_managers' do

    context "issue is for Central, NCN 1 and Tower Hamlets" do
      let(:issue) { FactoryGirl.create(:issue) }
      before(:each) do
        issue.update_attribute :administrative_area, tower_hamlets_area
      end

      context "ranger assigned to group Central, NCN 1 and Tower Hamlets" do
        before(:each) do
          ranger.groups << central_group
          ranger.routes << route_ncn1
          ranger.administrative_areas << tower_hamlets_area
        end

        it "does not include ranger" do
          issue.route_section_managers.include?(ranger).should == true
        end
      end

      context "ranger assigned to group Central, NCN 1 and Islington" do
        before(:each) do
          ranger.groups << central_group
          ranger.routes << route_ncn1
          ranger.administrative_areas << islington_area
        end

        it "does not include ranger" do
          issue.route_section_managers.include?(ranger).should == false
        end
      end

      context "ranger assigned to group Central, NCN 1 and no area" do
        before(:each) do
          ranger.groups << central_group
          ranger.routes << route_ncn1
          ranger.administrative_areas = []
          ranger.save!
        end

        it "includes ranger" do
          issue.route_section_managers.include?(ranger).should == true
        end
      end

      context "ranger assigned to group Central and no route or area" do
        before(:each) do
          ranger.groups << central_group
          ranger.routes = []
          ranger.administrative_areas = []
          ranger.save!
        end

        it "includes ranger" do
          issue.route_section_managers.include?(ranger).should == true
        end
      end
    end

    context "staff user assigned to NCN 1" do
      context "has no group or area" do
        before(:each) do
          staff.routes << route_ncn1
        end
        context "issue for North & Enfield & NCN 1" do
          let(:issue) { FactoryGirl.create(:issue) }
          let(:enfield_area) { AdministrativeArea.find_by_short_name("Enfield") || FactoryGirl.create(:administrative_area, name: 'Enfield', short_name: 'Enfield') }
          let(:north_group) { Group.find_by_name('North') || FactoryGirl.create(:group, name: 'North') }
          before(:each) do
            issue.update_attributes administrative_area: enfield_area, group: north_group, route: route_ncn1
          end

          it "returns staff user" do
            issue.route_section_managers.should eq([staff])
          end
        end
      end
    end

    context "staff user assigned to London Central but no area or route" do
      before(:each) do
        staff.groups << central_group
      end
      context "issue for central & islington & NCN 1" do
        let(:issue) { FactoryGirl.create(:issue) }
        before(:each) do
          issue.update_attribute :administrative_area, islington_area
        end

        it "returns staff user" do
          issue.route_section_managers.should eq([staff])
        end
      end
    end

    context "users except guest assigned to London region" do
      context "& central group" do
        before(:each) do
          volunteer.groups << central_group
          ranger.groups << central_group
          coordinator.groups << central_group
          staff.groups << central_group
        end
        context "& Islington area" do
          before(:each) do
            volunteer.administrative_areas << islington_area
            ranger.administrative_areas << islington_area
            coordinator.administrative_areas << islington_area
            staff.administrative_areas << islington_area
          end
          context "& NCN 1" do
            before(:each) do
              volunteer.routes << route_ncn1
              ranger.routes << route_ncn1
              coordinator.routes << route_ncn1
              staff.routes << route_ncn1
            end

            context "issue for central & islington & NCN 1" do
              let(:issue) { FactoryGirl.create(:issue) }
              before(:each) do
                issue.update_attribute :administrative_area, islington_area
              end

              it "returns all users except guest" do
                route_section_managers = issue.route_section_managers
                route_section_managers.include?(volunteer).should eq(true)
                route_section_managers.include?(ranger).should eq(true)
                route_section_managers.include?(coordinator).should eq(true)
                route_section_managers.include?(staff).should eq(true)
              end
            end

            context "issue for central & islington & NCN 2" do
              let(:route_ncn2) { Route.find_by_name('NCN 2') || FactoryGirl.create(:route, name: 'NCN 2') }
              let(:issue) { FactoryGirl.create(:issue) }
              before(:each) do
                issue.route = route_ncn2
                issue.administrative_area = islington_area
                issue.save
              end

              it "return no users" do
                issue.route_section_managers.empty?.should be(true)
              end
            end
          end
        end
      end
    end
  end
end
