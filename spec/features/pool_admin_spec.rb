require 'rails_helper'

RSpec.feature "Pool Management", type: :feature do
  context "Create" do
    scenario "A user can create a new pool" do
      given_that_a_season_has_been_created
      and_I_am_a_logged_in_user
      when_I_create_a_pool
      then_the_pool_should_show_up_in_my_profile
    end
  end
  
  context "update" do
    scenario "Can update a pool name", js: true do
      given_that_a_season_has_been_created
      and_I_am_a_logged_in_user
      and_I_have_created_a_pool
      when_I_update_the_pool_name
      then_the_new_pool_name_should_be_in_my_profile
    end
  end
  
  context "Delete" do
    scenario "Deleting a pool", js: true do
      given_that_a_season_has_been_created
      and_I_am_a_logged_in_user
      and_I_have_created_a_pool
      when_I_delete_a_pool
      then_the_pool_should_not_appear_in_my_profile
    
    end
  end
  
    # Given Definitions
  
    def given_that_a_season_has_been_created
      @admin_user =  FactoryBot.create(:admin)
      sign_in @admin_user
      @season = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 4, num_games: 4)
      @season.setState(Season::STATES[:Open])
#      sign_out @admin_user requires javascript and that is not setup yet
    end
  
    # And Definitions
  
    def and_I_am_a_logged_in_user
# Need to fix the signout portion of given_that_a_season_has_been_created
# before we can sign in as a new user
#      @user =  FactoryGirl.create(:user)
#      sign_in @_user
      @user = @admin_user
    end
  
    def and_I_have_created_a_pool
      when_I_create_a_pool
    end
  
    # When Definitions
  
    def when_I_create_a_pool
      visit new_pool_path
      fill_in 'pool_name',       with: "Test Pool"
      click_button 'Create pool'
      @pool = Pool.find_by_name("Test Pool")
    end
  
    def when_I_update_the_pool_name
      click_link "Manage Pool"
      click_link "Edit pool"
      @pool.name = "Test Pool 2"
      fill_in 'pool_name',       with: @pool.name
      click_button "Save changes"
    end
  
    def when_I_delete_a_pool
      click_link "Manage Pool"
      click_link "Delete pool"
      page.driver.browser.switch_to.alert.accept
    end
  
    # Then Definitions
  
    def then_the_pool_should_show_up_in_my_profile
      visit user_path(@user)
      expect(page).to have_text("Test Pool")
    end
  
    def then_the_new_pool_name_should_be_in_my_profile
      visit user_path(@user)
      expect(page).to have_text("Test Pool 2")
    end
  
    def then_the_pool_should_not_appear_in_my_profile
      visit user_path(@user)
      expect(page).to_not have_text("Test Pool")
    end
end
