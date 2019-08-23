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

class Game < ApplicationRecord

  belongs_to :week

  validates :homeTeamIndex, inclusion: { :in => 0..100 }
  validates :awayTeamIndex, inclusion: { :in => 0..100 }

  # determine if <teamIndex> was the winner of the game
  def wonGame?(teamIndex)
    
    score_spread = self.awayTeamScore - self.homeTeamScore
    if score_spread != 0
      if score_spread < 0
        winTeamIndex = self.homeTeamIndex
      else
        winTeamIndex = self.awayTeamIndex
      end
      teamIndex == winTeamIndex
    else
      # The case of a tie return true because both teams won
      if teamIndex == self.homeTeamIndex || teamIndex == self.awayTeamIndex
        return true
      else
        return false
      end
    end
  end
  
  # Determine if the game has already started
  def game_started?
    cur_time = Time.zone.now 
    if cur_time.dst? 
      game_date = self.game_date
    else
      game_date = self.game_date + 1.hour
    end
    
    if cur_time > game_date
      return true
    end
    
    return false
  end
end
