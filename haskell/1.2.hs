main :: IO ()
main = do
  contents <- readFile "inputs/1.txt"
  let masses = map read (lines contents)
  let totalFuel = sum $ map fuel masses
  print totalFuel

fuel :: Int -> Int
fuel mass =
  let massFuel = (mass `div` 3) - 2
   in if massFuel <= 0
        then 0
        else massFuel + fuel massFuel
