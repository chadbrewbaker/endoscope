#cmake ./
#make

hlint ./
runghc hasktests/Unit.hs
#runghc hasktests/Profile.hs
runghc hasktests/Check.hs

#ruby testendo.rb

