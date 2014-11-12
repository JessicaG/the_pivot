require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5

describe 'super admin user', type: :feature do
  before  do
    @user = create(:user, role: 'super_admin')
    visit '/'
    fill_in 'email', with: "#{@user.email}"
    fill_in 'password', with: "#{@user.password}"
    click_on 'login'
  end

  context 'dashboard' do
    before do
      @vendor = create(:vendor)
      @user = create(:user, first_name: 'joe', email: 'abc@example.com', password: 'asdf', password_confirmation: 'asdf', role:'vendor_admin', vendor_id: @vendor.id)
      # visit '/'
      # fill_in 'email', with: "#{@user.email}"
      # fill_in 'password', with: "#{@user.password}"
      # click_on 'login'
    end

    it "can see all users" do
      visit '/super_admin'
      expect(page).to have_content("View Current Users")
      click_on 'View Current Users'
      expect(page).to have_content(@user.first_name)
    end
  end

  it 'can see all vendors' do
    visit '/super_admin'
    click_on 'Create New User or Administrator'
    expect(current_path).to eq new_super_admin_user_path
    expect(page).to have_content("Create A New User or Administrator")
  end

  it 'can create named categories for items' do
    visit '/super_admin'
    click_on('Create A New Category')
    expect(page).to have_content("Create New Category")
    fill_in "category_title", with: "New Category"
    click_on('Create Category')
    expect(page).to have_content("Your category has been successfully created!")
  end

  it 'can see new vendor requests'

  it 'can approve a new vendor request'

  it 'can decline a new vendor request'

  it 'can take a vendor offline temporarily'

  it 'can redirect to root if a restaurant is temporarily offline'

  it 'can display a maintenance message for a vendor that is offline'

  it 'can bring an offline restaurant back online'

  it 'can override/assist restaurant admins'

end
