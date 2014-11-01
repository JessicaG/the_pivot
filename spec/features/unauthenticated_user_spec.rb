require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5

describe 'unauthenticated user', type: :feature do
  include Capybara::DSL

  context "browse by dropdown from header" do
    before do
      @vendor1 = create(:vendor)
      @vendor2 = create(:vendor, name: 'second store', description: 'a store that sells first aid', slug: '/second_store')
      @item = create(:item, vendor: @vendor1, title: 'barney band aids')
      @first_aid_category = create(:category, title: 'First Aid')
    end

    it "can browse by all vendors" do
      visit '/'
      within('.dropdown-menu') do
        assert page.has_content?('Vendors')
        click_link 'Vendors'
      end
      expect(current_path).to eq(vendors_path)
      assert page.has_content?('All Vendors')
      assert page.has_content?('first store')
      assert page.has_content?('second store')
      click_link 'first store'
      expect(current_path).to eq(vendor_path(@vendor1))
      expect(page).to have_content 'barney band aids'
    end

    it "can browse all categories" do
      visit '/'
      within('.dropdown-menu') do
        assert page.has_content?('Categories')
        click_link 'Categories'
      end
      expect(page).to have_content 'All Categories'
      expect(page).to have_content 'First Aid'
      click_link 'First Aid'
      expect(current_path).to eq(category_path(@first_aid_category))
      expect(page).to have_content 'barney band aids'
    end

    it "can browse all items" do
      visit '/'
      within('.dropdown-menu') do
        assert page.has_content?('Items')
        click_link 'Items'
      end
      expect(current_path).to eq(items_path)
      expect(page).to have_content 'Categories'
      expect(page).to have_content 'barney band aids'
      expect(current_path).to eq(items_path)
    end
  end


  context "from items page" do
    before do
      @vendor = create(:vendor)
      @first_aid_category = create(:category, title: 'First Aid')
      @item = create(:item, vendor: @vendor, title: 'Mickey band aids', categories: [@first_aid_category])
    end

    it "can browse items by category", js: true do
      visit items_path
      expect(page).to have_content "#{@item.title}"
      expect(page).to have_css '#category_list'
      within('#category_list') do
       expect(page).to have_content "First Aid"
#        expect(page).to have_css "##{@first_aid_category.title.split.join('_')}"
      end
      find('#First_Aid').trigger('click')
      expect(page).to have_content "#{@first_aid_category.title}"
      expect(page).to have_content "#{@item.title}"
    end

    it "can view a single item" do
      visit items_path
      within(".grid-item") do
        click_on 'Mickey band aids'
      end
      expect(current_path).to eq item_path(@item)
      expect(page).to have_content "#{@item.title.capitalize}"
    end
  end


  context "creating an account" do
    it "can create an account" do
      visit '/'
      click_link 'Create Account'
      expect(current_path).to eq new_user_path
      fill_in 'First name', with: 'Joe'
      fill_in 'Last name', with: 'Smithers'
      fill_in 'Nickname', with: 'jsmithers1000'
      fill_in 'Email', with: 'jsmithers@example.com'
      fill_in 'Password', with: 'jsmithers@example.com'
      fill_in 'Password confirmation', with: 'jsmithers@example.com'
      click_button 'Create Account'
      expect(page).to have_content "Your account was successfully created!"
    end

    it "cannot create an account with invalid data" do
      visit '/'
      click_on 'Create Account'
      fill_in 'Email', with: 'awef'
      click_button 'Create Account'
      expect(current_path).to eq users_path
      expect(page).to have_content "Please be sure to include a name and a valid email."
    end
  end


  context "authentication" do
    it "can login" do
      user = create(:user, first_name: 'joe', email: 'abc@example.com', password: 'asdf', password_confirmation: 'asdf')
      visit '/'
      fill_in 'email', with: "#{user.email}"
      fill_in 'password', with: "#{user.password}"
      click_on 'login'
      expect(page).to have_content 'Welcome knownothing!'
      expect(current_path).to eq items_path
      expect(page).to_not have_css '#email'
    end

    it "cannot login with invalid credentials" do
      user = create(:user, first_name: 'joe', email: 'abc@example.com', password: 'asdf', password_confirmation: 'asdf')
      visit '/'
      fill_in 'email', with: "imdrunk"
      fill_in 'password', with: "toodrunktologin"
      click_on 'login'
      expect(page).to have_content 'Invalid Login'
      expect(current_path).to eq root_path
    end
  end


  context "authorization" do
    it "cannot view another user's private data" do
      user = create(:user, first_name: 'joe', email: 'abc@example.com', password: 'asdf', password_confirmation: 'asdf')
      visit edit_user_path(user)
      expect(current_path).to eq(login_path)
      expect(page).to have_content('You are not authorized to access this page')
    end

    it "cannot view the administrator screens or use administrator functionality" do
      visit '/admin'
      expect(current_path).to eq(items_path)
      expect(page).to have_content('You are not authorized to access this page')
    end

    it "cannot make themselves an administrator" do
      visit new_user_path
      expect(page).to_not have_content('Role')
    end
  end


  context "when using the cart", js: true do
    before do
      create(:item, title: 'red t-shirt')
      visit items_path
      click_on 'Add to cart'
      expect(page).to have_content 'Item added to your cart!'
    end

    it "can add an item to cart" do
      within('.cart-container') do
        expect(page).to have_content '1'
        find('a').click
      end
      expect(current_path).to eq(cart_edit_path)
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('red t-shirt')
    end

    it "can add a multiple of the same item to cart" do
      fill_in 'quantity', with: "3"
      click_on 'Add to cart'
      within('.cart-container') do
        expect(page).to have_content '4'
      end
    end

    it "can update the quantity of an item in the cart" do
      visit cart_edit_path
      fill_in('quantity', with: '2')
      find('#update_quantity').click
      within('.cart-container') do
        expect(page).to have_content '2'
      end
      selected = find('#quantity').value
      expect(selected).to eq('2')
    end

    it "can remove an item from the cart" do
      visit cart_edit_path
      find("#remove_item").click
      within('.cart-container') do
        expect(page).to have_content '0'
      end
    end

    it "can clear the cart" do
      visit cart_edit_path
      click_on 'Clear My Cart'
      within('.cart-container') do
        expect(page).to have_content '0'
      end
    end

    it 'can log in, which does not clear the cart' do
      visit root_path
      within('.cart-container') do
        expect(page).to have_content '1'
      end
      user = create(:user, first_name: 'joe', email: 'abc@example.com', password: 'asdf', password_confirmation: 'asdf')
      visit '/'
      fill_in 'email', with: "#{user.email}"
      fill_in 'password', with: "#{user.password}"
      click_on 'login'
      expect(page).to have_content 'Welcome knownothing!'
      expect(current_path).to eq items_path
      within('.cart-container') do
        expect(page).to have_content '1'
      end
    end

    it 'cannot checkout' do
      visit cart_edit_path
      expect(page).to have_content 'Login To Checkout'
    end
  end
end


describe "What's good here?" do
  it "can see the posted reviews" do
    visit '/items/1'
    expect(page).to have_content 'Reviews'
  end

  it 'can see the average of the ratings' do
    visit '/items/1'
    expect(page).to have_content "Average"
  end
end
