main :: IO ()
main = do
  contents <- readFile "inputs/1.txt"
  let masses = map read (lines contents)
  let totalFuel = sum $ map fuel masses
  putStrLn (show totalFuel)

fuel :: Int -> Int
fuel mass =
  (mass `div` 3) - 2
