require 'rails_helper'

RSpec.describe IssuesController, type: :controller do

  describe "GET #index" do

    context "no attributes" do

      before(:each) do
        r = Region.create(name: 'Central')
        u = User.create( name: 'User Name',
                        email: 'user@email.com',
                        role: 'ranger',
                        password: 'asdfasdf',
                        region_id: r.id )
        sign_in u
      end

      it "does not raise error" do
        expect{ get :index }.not_to raise_error
      end
    end
  end

end
