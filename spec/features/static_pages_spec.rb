require 'rails_helper'

RSpec.feature "Static pages", type: :feature do

  subject { page }

  feature "when visiting the Home page and not signed in" do
    let(:user) { FactoryBot.create(:user) }
    before { visit root_path }

    scenario { should have_content('Football Pool Mania') }
    scenario { should have_title(full_title('')) }
    scenario "should be able to do a login" do
      fill_in 'email',    with: user.email.upcase
      fill_in 'password', with: user.password
      click_button 'Sign in'
      expect(should have_title(full_title(user.name)))
    end
    
    scenario "should have link to create user page" do
      click_link("Sign up now!")
      expect(should have_title(full_title('Sign up')))
    end
      
    scenario "should have link to login page" do
      click_link("Sign in")
      expect(should have_title(full_title('Sign in')))
    end
  end

  feature "when visiting the Help page" do
    before { visit help_path }

    scenario { should have_content('Help') }
    scenario { should have_title(full_title('Help')) }
  end

  feature "when visiting the About page" do
    before { visit about_path }

    scenario { should have_content('About') }
    scenario { should have_title(full_title('About Us')) }
  end

  feature "when visiting the Contact page" do
    before { visit contact_path }

    scenario { should have_selector('h1', text: 'Contact') }
    scenario { should have_title(full_title('Contact')) }
  end
end
