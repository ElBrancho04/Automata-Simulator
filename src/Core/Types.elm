module Core.Types exposing (..)

type Cell = Alive | Dead
type alias Grid = List (List Cell)
type alias Rules = { birth : List Int, survive : List Int }
type alias Position = (Int, Int)

type Page = ConfigPage | SimulationPage

type alias ConfigState =
    { grid : Grid
    , rules : Rules
    , ruleInput : String -- <--- Agregamos esto para el campo de texto
    , width : Int
    , height : Int
    }

type alias SimulationState =
    { grid : Grid
    , rules : Rules
    , generation : Int
    , isPlaying : Bool
    }

type alias AppState =
    { currentPage : Page
    , configState : ConfigState
    , simulationState : SimulationState
    }