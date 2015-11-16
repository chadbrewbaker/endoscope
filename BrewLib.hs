module BrewLib where
import Control.Monad

powset = Control.Monad.filterM (const [True, False])
trans x = replicateM (length x) x
z2n n = replicateM n (replicateM n [0,1])


