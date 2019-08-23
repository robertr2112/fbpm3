# == Schema Information
#
# Table name: games
#
#  id            :integer          not null, primary key
#  homeTeamIndex :integer
#  awayTeamIndex :integer
#  spread        :integer
#  week_id       :integer
#  homeTeamScore :integer          default(0)
#  awayTeamScore :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  game_date     :datetime
#

require 'rails_helper'

describe Game do

  let(:season) { FactoryBot.create(:season) }
  let(:week)   { FactoryBot.create(:week) }
  
  before(:each) do
    @game= week.games.create(homeTeamIndex: 0, awayTeamIndex: 1,
                              spread: 3.5)
  end

  subject {@game}

  it { should respond_to(:week_id) }
  it { should respond_to(:homeTeamIndex) }
  it { should respond_to(:awayTeamIndex) }
  it { should respond_to(:spread) }
  it { should respond_to(:homeTeamScore) }
  it { should respond_to(:awayTeamScore) }
  it { should respond_to(:wonGame?) }

  it { should be_valid }

  describe "and week associations" do

    it "should have the right associated week id" do
      @week_id = @game.week_id
      expect(@week_id).to eq week.id
    end
  end

  describe "validations" do
    describe "should reject an invalid homeTeamIndex > 100" do
      before { @game.homeTeamIndex = 101}
      it { should_not be_valid }
    end

    describe "should reject an invalid homeTeamIndex < 0" do
      before { @game.homeTeamIndex = -1}
      it { should_not be_valid }
    end

    describe "should reject an invalid awayTeamIndex > 100" do
      before { @game.awayTeamIndex = 101}
      it { should_not be_valid }
    end
    
    describe "should reject an invalid awayTeamIndex < 0" do
      before { @game.awayTeamIndex = -1}
      it { should_not be_valid }
    end
  end
  
  describe "wonGame?" do
    describe "when homeTeamIndex has higher score" do
      before do
        @game.homeTeamScore = 30
        @game.awayTeamScore = 20
      end
      
      it "should say homeTeamIndex is true" do
        winner = @game.wonGame?(@game.homeTeamIndex)
        expect(winner).to eq true
      end
      
      it "should say awayTeamIndex is false" do
        winner = @game.wonGame?(@game.awayTeamIndex)
        expect(winner).to eq false
      end
    end
    
    describe "when awayTeamIndex has higher score" do
      before do
        @game.homeTeamScore = 20
        @game.awayTeamScore = 30
      end
      
      it "should say homeTeamIndex is false" do
        winner = @game.wonGame?(@game.homeTeamIndex)
        expect(winner).to eq false
      end
      
      it "should say awayTeamIndex is true" do
        winner = @game.wonGame?(@game.awayTeamIndex)
        expect(winner).to eq true
      end
    end
    
    describe "when homeTeamScore == awayTeamsScore" do
      before do
        @game.homeTeamScore = 30
        @game.awayTeamScore = 30
      end
      
      it "should say homeTeamIndex is true" do
        winner = @game.wonGame?(@game.homeTeamIndex)
        expect(winner).to eq true
      end
      
      it "should say awayTeamIndex is true" do
        winner = @game.wonGame?(@game.awayTeamIndex)
        expect(winner).to eq true
      end
    end
  end
end
