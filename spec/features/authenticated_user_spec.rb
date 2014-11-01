require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5

describe 'authenticated user,', type: :feature do
  include Capybara::DSL

	before do
		user = create(:user, id: 1, first_name: 'joe', email: 'abc@example.com', password: 'asdf', password_confirmation: 'asdf')
    visit '/'
    fill_in 'email', with: "#{user.email}"
    fill_in 'password', with: "#{user.password}"
    click_on 'login'
	end

  context "when browsing and ordering," do
    before do
      @vendor = create(:vendor)
      # @vendor2 = create(:vendor, name: 'second store', description: 'a store that sells first aid', slug: '/second_store')
      @category = create(:category)
      @item = create(:item, vendor: @vendor, categories: [@category])
    end

  	it 'can browse all items' do
      visit '/'
      within('.dropdown-menu') do
        assert page.has_content?('Items')
        click_link 'Items'
      end
      expect(current_path).to eq(items_path)
      expect(page).to have_css '.grid-item'
  	end

  	it 'can browse items by category' do
      visit '/'
      within('.dropdown-menu') do
        assert page.has_content?('Categories')
        click_link 'Categories'
      end
      expect(current_path).to eq(categories_path)
      expect(page).to have_css '.categories-list'
      within('.categories-list') do
        assert page.has_content?("#{@category.title}")
        click_link "#{@category.title}"
      end
      expect(current_path).to eq(category_path(@category))
      expect(page).to have_content "#{@category.title.capitalize}"
      expect(page).to have_content "#{@item.title}"

  	end

  	it 'can add item to cart', js: true do
      visit items_path
      find('#add_to_cart').click
      expect(page).to have_content 'Item added to your cart!'
      within('.cart-container') do
          expect(page).to have_content '1'
        end
  	end

  	it 'can view my cart' do
  		within('.cart-container') do
          find('a').click
        end
  		expect(current_path).to eq(cart_edit_path)
      expect(page).to have_content('Your Cart')
  	end

  	it 'can remove an item from my cart', js: true do
      visit items_path
      find('#add_to_cart').click
      expect(page).to have_content 'Item added to your cart!'
      visit cart_edit_path
      find("#remove_item").click
      within('.cart-container') do
        expect(page).to have_content '0'
      end
	   end

  	it "can update the quantity of an item in the cart", js: true do
      visit items_path
      find('#add_to_cart').click
      expect(page).to have_content 'Item added to your cart!'
      visit cart_edit_path
      fill_in('quantity', with: '2')
      find('#update_quantity').click
      within('.cart-container') do
        expect(page).to have_content '2'
      end
      selected = find('#quantity').value
      expect(selected).to eq('2')
    end
  end

  it "can logout" do
  	visit '/'
    expect(page).to have_content 'Logout'
    click_on 'Logout'
    expect(page).to have_css '#email'
    expect(page).to have_css '#password'
  end

  it 'can view past orders with links to display each order' do
    visit '/'
    click_on 'My Profile'
    click_on 'Your Orders'
    expect(page).to have_content 'Order Status'
  end

	xit 'cannot view another users order' do
    #this should work? Any other way to expect a routing error?
    expect(visit '/users/3/orders').to raise_error( ActionController::RoutingError)
  end

	it 'cannot access admin item pages' do
		small_plates_category = create(:category, title: 'Small Plates')
		create(:item, id: 1, title: 'Second Food', categories: [small_plates_category])
		visit '/admin/items/1/edit'
		expect(page).to_not have_content "Edit Item"
		expect(current_path).to eq(items_path)
		expect(page).to have_content "You are not authorized to access this page."
		visit '/admin/items/new'
		expect(page).to_not have_content "Create New Item"
    expect(current_path).to eq(items_path)
		expect(page).to have_content "You are not authorized to access this page."
	end

  it 'cannot access admin user pages' do
    visit '/admin/users/1/edit'
    expect(page).to_not have_content "User or Admin?"
  end

	it 'cannot make itself an admin' do
		visit '/users/1/edit'
		expect(page).to_not have_content "User or Admin"
	end

  it 'cannot add a retired item to the cart' do
      visit '/items/1'
      expect(page).to have_content "Second Food"
      visit '/items'
      expect(page).to_not have_content "Second Food"
  end

  it 'can view a retired items page' do
      visit '/items/1'
      expect(page).to have_content "Second Food"
  end

end

describe 'authenticated user order display page' do
    before do
      user = create(:user, id: 1, first_name: 'joe', email: 'abc@example.com', password: 'asdf', password_confirmation: 'asdf')
      small_plates_category = create(:category, title: 'Small Plates')
      item = create(:item, id: 1, title: 'Second Food', categories: [small_plates_category], active: true)
      @order = create(:order, user_id: 1, items: [item] )
      visit '/'
      fill_in 'email', with: "#{user.email}"
      fill_in 'password', with: "#{user.password}"
      click_on 'login'
      click_on 'My Profile'
      click_on 'Your Orders'
    end

    it 'displays item with quantity ordered' do
      click_on '1'
      expect(page).to have_content "Second Food"
      expect(page).to have_content "1"
    end

    it 'shows line-item subtotals' do
      click_on '2'
      expect(page).to have_content 'Second Food 1 $1.00'
    end

    it 'links to each item description' do
      click_on '3'
      click_on 'Second Food'
      expect(page).to have_content "Second food"
    end

    it 'shows current status of an order' do
      @order.status = 'pending'
      click_on '4'
      expect(page).to have_content "Order Status"
    end

    it 'shows total order price' do
      click_on '5'
      expect(page).to have_content "Price $1.00"
    end

    it 'shows date and time order was submitted'
    it 'shows timestamp when order was completed'
    it 'shows timestamp when order was cancelled'
end
