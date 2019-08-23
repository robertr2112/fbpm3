FactoryBot.define  do
  factory :user do
    sequence(:name)       { |n| "Person #{n}" }
    sequence(:user_name)  { |n| "Nickname #{n}" }
    sequence(:email)      { |n| "person-#{n}@example.com" }
    password              { "foobar" }
    password_confirmation { "foobar" }
    confirmed             { true }

    factory :supervisor do
      supervisor { true }
      admin      { true }
    end
    
    factory :admin do
      admin { true }
    end

    factory :unconfirmed_user do
      confirmed { false }
    end
  end
  
  factory :user_with_pool, parent: :user do
    
    transient do
      season   { 1 }
      pool     { nil }
    end
    
    after(:create) do |user, evaluator|
      if evaluator.pool.nil? 
        pool= create(:pool, season: evaluator.season)
        user.admin = true
      else
        pool = evaluator.pool
      end
      user.pools <<  pool
    end
  end
  
  factory :user_with_pool_and_entry, parent: :user do
    
    transient do
      season       { 1 }
      num_entries  { 1 }
      pool         { nil }
    end
    
    after(:create) do |user, evaluator|
      if evaluator.pool.nil? 
        user.admin = true
        pool = create(:pool_with_entries, user: user, num_entries: 1, season: evaluator.season)
      else
        pool = evaluator.pool
        pool.entries << create(:entry, user: user, pool: pool)
      end
      user.pools << pool
    end
  end
  
  factory :pool do
    sequence(:name) { |n| "Pool-#{n}" }
    poolType              { 2 }
    isPublic              { true }
    password              { "foobar" }
    
    transient do
      week_id      { 1 }
      num_entries  { 1 }
      user         { nil }
    end
    
    factory :pool_with_entries do
      after (:create) do |pool, evaluator|
        1.upto(evaluator.num_entries) do |n|
          create(:entry, pool: pool, user: evaluator.user)
        end
      end
    end
  end

  # join table factory - :feature
  factory :pool_membership do |membership|
    membership.association :user
    membership.association :pool, :factory => :pool
  end
  
  factory :game do
#   homeTeamIndex 1
#   awayTeamIndex 17
    sequence(:homeTeamIndex, (1..16).cycle) { |n| n }
    sequence(:awayTeamIndex, (17..32).cycle) { |n| n }
    game_date { Time.zone.now + 10.minutes }
    week
  end
  
  factory :game_pick do
    chosenTeamIndex  { 0 }
    pick
    
  end
  
  factory :pick do
    week_number { 1 }
    week_id     { nil }
    entry
    
    transient do
      teamIndex { 0 }
    end
    
    factory :pick_with_game_pick do
      after (:create) do |pick, evaluator|
        pick.game_picks << create(:game_pick, pick: pick, chosenTeamIndex: evaluator.teamIndex)
      end
    end

  end
  
  factory :entry do
    sequence(:name)   { |n| "Entry #{n}" }
    survivorStatusIn  { true }
    supTotalPoints    { 0 }
    user
    pool
    
  end
  
  factory :week do
    state        { 0 }
    week_number  { 1 }
    season
    
    transient do
      num_games  { 5 }
    end
    
    factory :week_with_games do
      
      after (:create) do |week, evaluator|
        home_games = (1..16).sort_by{rand}
        away_games = (17..32).sort_by{rand}
        1.upto(evaluator.num_games) do |n|
          create(:game, week: week)
#         create(:game, week: week, homeTeamIndex: home_games[n-1],
#                                   awayTeamIndex: away_games[n-1])
        end
      end
    end
  end
  
  factory :season do
    year             { "2015" }
    state            { 0 }
    nfl_league       { 1 }
    current_week     { 1 }
    number_of_weeks  { 0 }
    
      transient do
        num_weeks  { 1 }
        num_games  { 1 }
      end
      
    factory :season_with_weeks do
      
      after(:create) do |season, evaluator|
       1.upto(evaluator.num_weeks) do |n|
         create(:week, season: season, week_number: n)
       end
       season.number_of_weeks = evaluator.num_weeks
      end
    end
    
    factory :season_with_weeks_and_games do
      
      after(:create) do |season, evaluator|
       1.upto(evaluator.num_weeks) do |n|
         create(:week_with_games, season: season, week_number: n, num_games: evaluator.num_games)
       end
       season.number_of_weeks = evaluator.num_weeks
      end
    end
  end
  
end

