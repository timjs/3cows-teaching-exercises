module Main


import iTasks



// Types ///////////////////////////////////////////////////////////////////////


// Helpers /////////////////////////////////////////////////////////////////////


// Stores //////////////////////////////////////////////////////////////////////


// Checks //////////////////////////////////////////////////////////////////////


// Tasks ///////////////////////////////////////////////////////////////////////


main :: Task ...
main =
  ...



// Boilerplate /////////////////////////////////////////////////////////////////


// derive class iTask ...


Start :: *World -> *World
Start world = startEngine (main <<@ InWindow) world


(>>?) infixl 1 :: (Task a) [( String, a -> Bool, a -> Task b )] -> Task b | iTask a & iTask b
(>>?) task options = task >>* map trans options
where
  trans ( a, p, t ) = OnAction (Action a) (ifValue p t)


($=) infixr 2 :: (ReadWriteShared r w) (r -> w) -> Task w | iTask r & iTask w
($=) share fun = upd fun share
