RSpec.describe WelcomeController, :type => :controller do
  describe "GET code" do
    it 'redirects to the source code' do
      get :code
      expect(response).to redirect_to("https://github.com/ianderse/dinner_dash")
    end
  end
end
