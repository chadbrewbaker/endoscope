#cmake ./
#make

hlint ./
runghc test/Unit.hs
#runghc test/Profile.hs
runghc test/Check.hs

#ruby testendo.rb

