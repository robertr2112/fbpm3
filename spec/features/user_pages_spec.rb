require 'rails_helper'

RSpec.feature "User pages", type: :feature do

  subject { page }

  feature "index" do
    let (:user){ 
      FactoryBot.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    scenario { should have_title('All users') }
    scenario { should have_content('All users') }

    context "pagination" do

      before(:all) { 30.times { FactoryBot.create(:user) } }
      after(:all)  { User.delete_all }

      scenario { should have_selector('div.pagination') }

      scenario "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    context "delete links" do
      let (:user2) { FactoryBot.create(:user) }

      scenario { expect(page).not_to have_link('delete', href: user_path(user2)) }

      context "as a supervisor user" do
        let(:supervisor) { FactoryBot.create(:supervisor) }
        before do
          sign_in supervisor
          visit users_path
        end

        scenario { expect(page).to have_link('delete', href: user_path(user)) }
        scenario "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        scenario { should_not have_link('delete', href: user_path(supervisor)) }
      end
    end
  end

  feature "index" do
    before do
      sign_in FactoryBot.create(:user)
      FactoryBot.create(:user, name: "Bob", email: "bob@example.com")
      FactoryBot.create(:user, name: "Ben", email: "ben@example.com")
      visit users_path
    end
    
    scenario { 
      save_and_open_page
      should have_title('All users') }
    scenario { should have_content('All users') }

    scenario "should list each user" do
      User.all.each do |user|
        expect(page).to have_selector('li', text: user.name)
      end
    end
  end

  feature "profile page" do
    let(:user) { FactoryBot.create(:user) }
    before do 
      sign_in user
      visit user_path(user)
    end

    scenario { should have_content(user.name) }
    scenario { should have_title(user.name) }
  end

  feature "signup page" do
    before { visit signup_path }

    scenario { should have_content('Sign up') }
    scenario { should have_title(full_title('Sign up')) }
  end
  
  feature "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    context "with invalid information" do
      scenario "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      context "after submission" do
        before { click_button submit }

        scenario { should have_title('Sign up') }
        scenario { should have_content('can\'t be blank') }
      end
    end

    context "with valid information" do
      before do
        fill_in 'user_name',                  with: "Example User"
        fill_in 'user_user_name',             with: "User1"
        fill_in 'user_email',                 with: "user1@example.com"
        fill_in 'user_password',              with: "foobar"
        fill_in 'user_password_confirmation', with: "foobar"
      end

      scenario "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      context "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user1@example.com') }

        scenario { should have_title(user.name) }
        scenario { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end

  feature "edit" do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in(user)
      visit edit_user_path(user)
    end
    
    context do
    end

    context "page" do
      scenario { should have_content("Update your profile") }
      scenario { should have_title("Edit user") }
      scenario { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    context "with invalid Name" do
      before do 
        fill_in 'user_name', with: ""
        click_button "Update Profile" 
      end
 
      scenario { should have_content('can\'t be blank') }
    end

    context "with invalid Name" do
      before do 
        fill_in 'user_user_name', with: ""
        click_button "Update Profile" 
      end
 
      scenario { should have_content('can\'t be blank') }
    end
 
    context "with invalid Email" do
      before do 
        fill_in 'user_email', with: ""
        click_button "Update Profile" 
      end
 
      scenario { should have_content('can\'t be blank') }
    end
 
    context "with invalid Password" do
      before do 
        fill_in 'user_password', with: ""
        click_button "Update Profile" 
      end
 
      scenario { should have_content('is too short') }
    end
    
    context "with invalid Password Confirmation" do
      before do 
        fill_in 'user_password_confirmation', with: ""
        click_button "Update Profile" 
      end
 
      scenario { should have_content('is too short') }
    
    end
    
    context "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_user_name)  { "Name1" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in 'user_name',                  with: new_name
        fill_in 'user_user_name',             with: new_user_name
        fill_in 'user_email',                 with: new_email
        fill_in 'user_password',              with: user.password
        fill_in 'user_password_confirmation', with: user.password
        click_button "Update Profile"
      end

      scenario { should have_title(new_name) }
      scenario { should have_selector('div.alert.alert-success') }
      scenario { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end
end


