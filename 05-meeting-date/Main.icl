module Main


import iTasks



// Types ///////////////////////////////////////////////////////////////////////


:: Name :== String


:: DateOption =
  { date :: Date
  , hour :: Int
  }


:: MeetingOption =
  { users :: [String]
  , date :: DateOption
  }



// Stores //////////////////////////////////////////////////////////////////////


users :: Shared [Name]
users =
 [ "Rinus"
 , "Peter"
 , "Mart"
 , "Tim"
 ]



// Helpers /////////////////////////////////////////////////////////////////////


initTable :: [Date] -> [MeetingOption]
initTable dates =
  [ { users = [], date = date } \\ date <- dates ]


updateTable :: Name [Int] [MeetingOption] -> [MeetingOption]
updateTable name indices options =
  [ { option & users = if (isMember j indices) [name : option.users] option.users }
  \\ j <- [0..] & option <- options
  ]



// Tasks ///////////////////////////////////////////////////////////////////////


main :: Task MeetingOption
main =
  defineMeetingPurpose >>= \purpose ->
  selectDatesToPropose >>= \dates ->
  selectAttendencees >>= \others ->
  askOthers purpose dates others >>= \options ->
  selectMeetingDate options >>= \chosen ->
  viewInformation "Date chosen:" [] chosen


defineMeetingPurpose :: Task String
defineMeetingPurpose =
  enterInformation "What is the purpose of the meeting?" []


selectDatesToPropose :: Task [DateOption]
selectDatesToPropose =
  enterInformation "Select the date(s) and time you propose to meet..." []


selectAttendencees :: Task [Name]
selectAttendencees =
  enterMultipleChoiceWithShared ("Who do you want to invite for the meeting?")
    [ChooseFromCheckGroup id] users


askOthers :: String [DateOption] [Name] -> Task MeetingOption
askOthers purpose dates others =
  withShared (initTable dates) askAll

  where

  askAll table =
    allTasks [ ( name, purpose ) @: askOne (toString name) \\ name <- others ]

  askOne name table =
    viewSharedInformation "Current Responses:" [] table
      ||-
    enterMultipleChoiceWithShared "Select the date(s) you can attend the meeting:"
      [ChooseFromGrid (\i -> dates!!i)] [0..length dates - 1] >>= \indices ->
    table $= updateTable indices


selectMeetingDate :: (Shared [MeetingOption]) -> Task MeetingOption
selectMeetingDate table =
  enterChoiceWithShared "Select the date for the meeting:" [ChooseFromGrid id] table



// Boilerplate /////////////////////////////////////////////////////////////////


derive class iTask DateOption, MeetingOption


Start :: *World -> *World
Start world = startEngine main world


(>>?) infixl 1 :: (Task a) [( String, a -> Bool, a -> Task b )] -> Task b | iTask a & iTask b
(>>?) task options = task >>* map trans options
where
  trans ( a, p, t ) = OnAction (Action a) (ifValue p t)


($=) infixr 2 :: (ReadWriteShared r w) (r -> w) -> Task w | iTask r & iTask w
($=) share fun = upd fun share
