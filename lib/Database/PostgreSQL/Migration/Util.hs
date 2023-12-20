module Database.PostgreSQL.Migration.Util where

import Data.Maybe (fromMaybe, listToMaybe)

f' :: String -> [String] -> String
f' str terms =
  case str of
    '%' : 's' : rest -> (fromMaybe "%s" . listToMaybe $ terms) ++ f' rest (drop 1 terms)
    '%' : '%' : 's' : rest -> '%' : 's' : f' rest terms
    a : rest -> a : f' rest terms
    [] -> []
