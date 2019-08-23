module AuthenticationHelper

  def sign_in(user, options={})
    if options[:no_capybara]
      # Sign in when not using Capybara.
      remember_token = User.new_remember_token
      cookies[:remember_token] = remember_token
      user.update_attribute(:remember_token, User.encrypt(remember_token))
    else
      visit signin_path
      find('#signin_email').set(user.email)
      find('#signin_password').set(user.password)
      find('#signin_button').click
    end
  end

  #  Here are the support routines to test out pools
 
  # add scores for all games and all weeks in the season, where all home teams win (for simplicity)
  # for each week, but leave current week as 1 and don't mark any weeks as final
  def add_season_games_scores(season)
    season.weeks.each do |week|
      week.games.each do |game|
        game.homeTeamScore = rand(18...42)
        game.awayTeamScore = rand(0...17)
        game.save
      end
    end
  end
   
  # will setup a pool with num_users number of users and num_entries number of
  # entries per user in entered season
  def setup_pool_with_users_and_entries(season, num_users, num_entries)
    users = Array.new
    users[0] = FactoryBot.create(:user_with_pool_and_entry, season: season)
    pool = users[0].pools.first
    1.upto(4) do |n|
      users[n] = FactoryBot.create(:user_with_pool_and_entry, season: season, pool: pool)
    end
    return users
  end
 
  #
  # This routine is used to make specified picks/forgot to picks for a given week, and
  # then finalize the week and update the pool with the results.  It takes a number of 
  # arguments:
  #             season          - This is the current season under test
  #             pool            - The pool under test
  #             users           - Array of users in the pool
  #             numUsersCorrect - The number of users to pick correctly for this week
  #             numUsersForgot  - The number of users to have forget to pick for this week
  #
  def pool_update_survivor_users(season, pool, users, numUsersCorrect, numUsersForgot)
    
    week = season.getCurrentWeek
    new_users = users
    numUsersForgot.times do
      new_users.shift
    end
    users_pick_winning_team(week, pool, new_users, numUsersCorrect) unless pool.pool_done
    week.setState(Week::STATES[:Final])
    
    # Call season.updatePools instead of directly calling pool.updateEntries directly so
    # we can share code with the tests that are testing out multiple week behavior.  This 
    # routine just calls pool.updateEntries and updates the current week of the season.  We
    # could do that separately in test code but it seems uncessary.
    #
    season.updatePools
    pool.reload
            
  end
  
  # Have num_users number of users pick the winning home team and the rest pick the away team
  def users_pick_winning_team(week, pool, users, num_users)
    
    user_count = 1
    users.each do |user|
      entry = pool.entries.where(user_id: user.id)[0]
      if user_count <= num_users then 
        team_index = week.games[0].homeTeamIndex
      else
        team_index = week.games[0].awayTeamIndex
      end
      
      new_pick = entry.picks.build(week_id: week.id, week_number: week.week_number)
      new_game_pick = new_pick.game_picks.build(chosenTeamIndex: team_index)
      new_game_pick.save
      new_pick.save
      
      user_count += 1
    end
  end
  
  def numberRemainingSurvivorEntries(pool)
    
    num_entries = 0
    pool.entries.each do |entry|
      if entry.survivorStatusIn then
        num_entries += 1
      end
    end
    return num_entries
  end
 
#module MailerMacros
#  def last_email
#    ActionMailer::Base.deliveries.last
#  end
#	
#  def extract_token_from_email(token_name)
#    mail_body = last_email.body.to_s
#    mail_body[/#{token_name.to_s}_token=([^"]+)/, 1]
#  end

 #
 # Debug code
 #
 #save_and_open_page
 #puts current_url
 #pry
 
end


