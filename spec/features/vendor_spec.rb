require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5

describe 'vendor', type: :feature do
  before do
    @vendor = create(:vendor)
    @item = create(:item, vendor: @vendor, title: 'band aids')
  end

  it 'views all vendor pages' do
    visit '/'
    within('.dropdown-menu') do
      assert page.has_content?('Vendors')
      click_link 'Vendors'
    end
    expect(current_path).to eq vendors_path
    expect(page).to have_link('first store')
  end

  it 'views a single vendor page' do
    visit vendors_path
    within('.vendors-list') do
      click_on('first store')
    end
    expect(current_path).to eq vendor_path(@vendor.id)
    expect(page).to have_link('band aids')
    expect(page).to_not have_content('error')
  end

  it 'can create a new vendor' do
    visit new_vendor_path
    fill_in("Name Your Store", with: 'Great Store')
    fill_in("Describe Your Store", with: 'So great')
    click_on 'Create My Store'
    expect(current_path).to eq root_path
    expect(page).to_not have_css('.errors')
  end

 xit 'can cannot create a new vendor with a duplicate name' do
    visit new_vendor_path
    fill_in("Name Your Store", with: 'first store')
    fill_in("Describe Your Store", with: 'So great')
    click_on 'Create My Store'
    expect(page).to have_content('Name has already been taken')
  end

end
