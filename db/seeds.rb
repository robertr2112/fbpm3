# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = User.new do |u|
  u.name = "Admin"
  u.user_name = "Admin"
  u.admin = true
  u.supervisor = true
  u.confirmed = true
  u.email = "admin@fbpm.com"
  u.password = "p8ssw0rd"
  u.password_confirmation = "p8ssw0rd"
end

admin.save!

Team.create name: "Arizona Cardinals", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/ari.jpeg"
Team.create name: "Atlanta Falcons", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/atl.jpeg"
Team.create name: "Baltimore Ravens", nfl: 1,
                                  imagePath: "nfl_teams/afcn/bal.jpeg"
Team.create name: "Buffalo Bills", nfl: 1,
                                  imagePath: "nfl_teams/afce/buf.jpeg"
Team.create name: "Carolina Panthers", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/car.jpeg"
Team.create name: "Chicago Bears", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/chi.jpeg"
Team.create name: "Cincinnati Bengals", nfl: 1,
                                  imagePath: "nfl_teams/afcn/cin.jpeg"
Team.create name: "Cleveland Browns", nfl: 1,
                                  imagePath: "nfl_teams/afcn/cle.jpeg"
Team.create name: "Dallas Cowboys", nfl: 1,
                                  imagePath: "nfl_teams/nfce/dal.jpeg"
Team.create name: "Denver Broncos", nfl: 1,
                                  imagePath: "nfl_teams/afcw/den.jpeg"
Team.create name: "Detroit Lions", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/det.jpeg"
Team.create name: "Green Bay Packers", nfl: 1,
                                  imagePath: "nfl_teams/nfcn/gb.jpeg"
Team.create name: "Houston Texans", nfl: 1,
                                  imagePath: "nfl_teams/afcs/hou.jpeg"
Team.create name: "Indianapolis Colts", nfl: 1,
                                  imagePath: "nfl_teams/afcs/ind.jpeg"
Team.create name: "Jacksonville Jaguars", nfl: 1,
                                  imagePath: "nfl_teams/afcs/jac.jpeg"
Team.create name: "Kansas City Chiefs", nfl: 1,
                                  imagePath: "nfl_teams/afcw/kc.jpeg"
Team.create name: "Los Angeles Chargers", nfl: 1,
                                  imagePath: "nfl_teams/afcw/lac.jpeg"
Team.create name: "Los Angeles Rams", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/lar.jpeg"
Team.create name: "Minnesota Vikings", nfl: 1,
                                   imagePath: "nfl_teams/nfcn/min.jpeg"
Team.create name: "Miami Dolphins", nfl: 1,
                                  imagePath: "nfl_teams/afce/mia.jpeg"
Team.create name: "New England Patriots", nfl: 1,
                                  imagePath: "nfl_teams/afce/ne.jpeg"
Team.create name: "New Orleans Saints", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/no.jpeg"
Team.create name: "New York Giants", nfl: 1,
                                  imagePath: "nfl_teams/nfce/nyg.jpeg"
Team.create name: "New York Jets", nfl: 1,
                                  imagePath: "nfl_teams/afce/nyj.jpeg"
Team.create name: "Oakland Raiders", nfl: 1,
                                  imagePath: "nfl_teams/afcw/oak.jpeg"
Team.create name: "Philadelphia Eagles", nfl: 1,
                                  imagePath: "nfl_teams/nfce/phi.jpeg"
Team.create name: "Pittsburgh Steelers", nfl: 1,
                                  imagePath: "nfl_teams/afcn/pit.jpeg"
Team.create name: "San Francisco 49ers", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/sf.jpeg"
Team.create name: "Seattle Seahawks", nfl: 1,
                                  imagePath: "nfl_teams/nfcw/sea.jpeg"
Team.create name: "Tampa Bay Buccaneers", nfl: 1,
                                  imagePath: "nfl_teams/nfcs/tb.jpeg"
Team.create name: "Tennessee Titans", nfl: 1,
                                  imagePath: "nfl_teams/afcs/ten.jpeg"
Team.create name: "Washington Redskins", nfl: 1,
                                  imagePath: "nfl_teams/nfce/was.jpeg"
