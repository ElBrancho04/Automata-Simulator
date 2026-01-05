module Core.Types exposing (..)

import Array exposing (Array)

type Cell = Alive | Dead
type alias Grid = Array (Array Cell)
type alias Rules = { birth : List Int, survive : List Int }
type alias Position = (Int, Int)

type Page = ConfigPage | SimulationPage
type BorderType = Toroidal | Finite

-- Tipos para detección de patrones
type PatternType
    = UnknownPattern
    | StaticPattern
    | Oscillator Int
    | Spaceship (Int, Int) Int
    | GrowingPattern
    | DyingPattern
    | ChaoticPattern
    | GliderGunPattern Int

-- Convertir patrón a string para mostrar
patternToString : PatternType -> String
patternToString pattern =
    case pattern of
        UnknownPattern -> "Analizando..."
        StaticPattern -> "🔘 Estático"
        Oscillator p -> "🔄 Oscilador (período " ++ String.fromInt p ++ ")"
        Spaceship (dx, dy) period -> "🚀 Nave (" ++ String.fromInt dx ++ "," ++ String.fromInt dy ++ ") cada " ++ String.fromInt period ++ " gen"
        GrowingPattern -> "📈 Creciendo"
        DyingPattern -> "📉 Extinguiéndose"
        ChaoticPattern -> "🌀 Caótico"
        GliderGunPattern p -> "🔫 Generador de planeadores (período " ++ String.fromInt p ++ ")"

type alias ConfigState =
    { grid : Grid
    , rules : Rules
    , ruleInput : String 
    , width : Int
    , height : Int
    , widthInput : String   -- Input temporal para ancho
    , heightInput : String  -- Input temporal para alto
    , borderType : BorderType
    , cellSize : Int
    }

type alias SimulationState =
    { grid : Grid
    , rules : Rules
    , generation : Int
    , isPlaying : Bool
    -- Campos para análisis de patrones
    , history : List Grid
    , detectedPattern : PatternType
    , analysisEnabled : Bool
    , borderType : BorderType
    , cellSize : Int
    }

type alias AppState =
    { currentPage : Page
    , configState : ConfigState
    , simulationState : SimulationState
    }