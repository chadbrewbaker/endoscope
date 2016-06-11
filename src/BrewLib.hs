module BrewLib where
import Control.Monad
import Data.Vector (toList, fromList, backpermute)

powset = Control.Monad.filterM (const [True, False])
trans x = replicateM (length x) x
z2n n = replicateM n (replicateM n [0,1])

transMult a b =  toList $backpermute (fromList a) (fromList b)

