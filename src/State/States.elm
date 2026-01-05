module State.States exposing (..)

import Core.Automata exposing (nextGeneration)
import Core.Grid exposing (emptyGrid, toggleCell)
import Core.Rules exposing (parseRules)
import Core.Types exposing (..)
import Core.PatternAnalysis
import Time
import Random
import Array

-- 1. MENSAJES
-- Definimos todo lo que puede ocurrir en la aplicación
type Msg
    = NoOp
    -- Acciones de Configuración
    | SetRuleInput String
    | ToggleConfigCell Position
    | StartSimulation
    | SetWidthInput String
    | SetHeightInput String
    | ApplyGridSize
    | SetBorderType BorderType
    | SetCellSize Int
    -- Acciones de Simulación
    | Tick Time.Posix
    | TogglePlay
    | StepGeneration
    | StopSimulation
    | RandomizeGrid
    | GridGenerated Grid
    | LoadPattern (List Position)
    | TogglePatternAnalysis
    | ResetToConwayDefaults

-- 2. INIT
-- Estado inicial de la aplicación
init : ( AppState, Cmd Msg )
init =
    let
        defaultWidth = 30
        defaultHeight = 30
        defaultRules = { birth = [3], survive = [2, 3] } -- Conway clásico
        defaultRuleStr = "B3/S23"
        defaultCellSize = 20
        
        initialConfig = 
            { grid = emptyGrid defaultWidth defaultHeight
            , rules = defaultRules
            , ruleInput = defaultRuleStr
            , width = defaultWidth
            , height = defaultHeight
            , widthInput = String.fromInt defaultWidth
            , heightInput = String.fromInt defaultHeight
            , borderType = Toroidal
            , cellSize = defaultCellSize
            }

        initialSimulation =
            { grid = emptyGrid defaultWidth defaultHeight
            , rules = defaultRules
            , generation = 0
            , isPlaying = False
            , history = []
            , detectedPattern = UnknownPattern
            , analysisEnabled = True
            , borderType = Toroidal
            , cellSize = defaultCellSize
            }
    in
    ( { currentPage = ConfigPage
      , configState = initialConfig
      , simulationState = initialSimulation
      }
    , Cmd.none
    )

-- 3. UPDATE
update : Msg -> AppState -> ( AppState, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        -------------------------
        -- Lógica de Configuración
        -------------------------
        SetRuleInput str ->
            let
                config = model.configState
                -- Intentamos parsear. Si falla, mantenemos las reglas anteriores
                -- pero actualizamos el input visualmente.
                newRules = 
                    case parseRules str of
                        Just r -> r
                        Nothing -> config.rules
                
                newConfig = { config | ruleInput = str, rules = newRules }
            in
            ( { model | configState = newConfig }, Cmd.none )

        ToggleConfigCell pos ->
            let
                config = model.configState
                newGrid = toggleCell pos config.grid
                newConfig = { config | grid = newGrid }
            in
            ( { model | configState = newConfig }, Cmd.none )

        StartSimulation ->
            let
                config = model.configState
                -- Copiamos el estado de config al estado de simulación
                newSimState = 
                    { grid = config.grid
                    , rules = config.rules
                    , generation = 0
                    , isPlaying = False
                    , history = []
                    , detectedPattern = UnknownPattern
                    , analysisEnabled = True
                    , borderType = config.borderType
                    , cellSize = config.cellSize
                    }
            in
            ( { model 
                | currentPage = SimulationPage
                , simulationState = newSimState 
              }
            , Cmd.none 
            )

        SetWidthInput str ->
            let
                config = model.configState
                newConfig = { config | widthInput = str }
            in
            ( { model | configState = newConfig }, Cmd.none )

        SetHeightInput str ->
            let
                config = model.configState
                newConfig = { config | heightInput = str }
            in
            ( { model | configState = newConfig }, Cmd.none )

        ApplyGridSize ->
            let
                config = model.configState
                newWidth = 
                    config.widthInput 
                        |> String.toInt 
                        |> Maybe.withDefault config.width
                        |> clamp 1 100
                newHeight = 
                    config.heightInput 
                        |> String.toInt 
                        |> Maybe.withDefault config.height
                        |> clamp 1 100
                newGrid = emptyGrid newWidth newHeight
                newConfig = 
                    { config 
                    | width = newWidth
                    , height = newHeight
                    , widthInput = String.fromInt newWidth
                    , heightInput = String.fromInt newHeight
                    , grid = newGrid 
                    }
            in
            ( { model | configState = newConfig }, Cmd.none )

        SetBorderType borderType ->
            let
                config = model.configState
                newConfig = { config | borderType = borderType }
            in
            ( { model | configState = newConfig }, Cmd.none )

        SetCellSize size ->
            let
                config = model.configState
                newSize = clamp 5 40 size
                newConfig = { config | cellSize = newSize }
            in
            ( { model | configState = newConfig }, Cmd.none )

        -------------------------
        -- Lógica de Simulación
        -------------------------
        Tick _ ->
            if model.simulationState.isPlaying then
                update StepGeneration model
            else
                ( model, Cmd.none )

        TogglePlay ->
            let
                sim = model.simulationState
                newSim = { sim | isPlaying = not sim.isPlaying }
            in
            ( { model | simulationState = newSim }, Cmd.none )

        StepGeneration ->
            let
                sim = model.simulationState
                newGrid = nextGeneration sim.borderType sim.rules sim.grid
                newHistory = 
                    (sim.grid :: sim.history)
                        |> List.take 20
                newPattern = 
                    if sim.analysisEnabled && List.length newHistory >= 2 then
                        Core.PatternAnalysis.analyzePattern newHistory
                    else
                        sim.detectedPattern
                newSim = 
                    { sim 
                    | grid = newGrid
                    , generation = sim.generation + 1
                    , history = newHistory
                    , detectedPattern = newPattern
                    }
            in
            ( { model | simulationState = newSim }, Cmd.none )

        StopSimulation ->
            -- Volvemos a la página de configuración y detenemos todo
            let
                sim = model.simulationState
                newSim = { sim | isPlaying = False }
            in
            ( { model 
                | currentPage = ConfigPage
                , simulationState = newSim
              }
            , Cmd.none 
            )
        RandomizeGrid ->
            let
                w = model.configState.width
                h = model.configState.height
            in
            ( model
            , Random.generate GridGenerated (randomGridGenerator w h)
            )

        -- 2. Elm nos devuelve la grilla generada
        GridGenerated newRandomGrid ->
            let
                config = model.configState
                newConfig = { config | grid = newRandomGrid }
            in
            ( { model | configState = newConfig }
            , Cmd.none 
            )
        LoadPattern patternPositions ->
            let
                config = model.configState
                
                -- Función auxiliar para aplicar offset (para que no aparezca en la esquina 0,0)
                offset = (5, 5) -- Movemos todo 5 celdas abajo y a la derecha
                
                adjustedPattern =
                    List.map (\(r, c) -> (r + Tuple.first offset, c + Tuple.second offset)) patternPositions

                -- APLICAMOS EL PATRÓN SOBRE LA GRILLA ACTUAL
                -- Usamos toggleCell repetidamente para cada punto del patrón
                newGrid = 
                    List.foldl 
                        Core.Grid.toggleCell 
                        config.grid 
                        adjustedPattern
                
                newConfig = { config | grid = newGrid }
            in
            ( { model | configState = newConfig }, Cmd.none )

        TogglePatternAnalysis ->
            let
                sim = model.simulationState
                newSim = { sim | analysisEnabled = not sim.analysisEnabled }
            in
            ( { model | simulationState = newSim }, Cmd.none )

        ResetToConwayDefaults ->
            let
                config = model.configState
                conwayRules = { birth = [3], survive = [2, 3] }
                conwayRuleStr = "B3/S23"
                
                -- Crear nueva grilla vacía del mismo tamaño
                newGrid = emptyGrid config.width config.height
                
                newConfig = 
                    { config 
                        | grid = newGrid
                        , rules = conwayRules
                        , ruleInput = conwayRuleStr
                    }
            in
            ( { model | configState = newConfig }, Cmd.none )

-- 4. SUBSCRIPTIONS
-- Aquí manejamos el "loop" de tiempo cuando el juego está corriendo
subscriptions : AppState -> Sub Msg
subscriptions model =
    case model.currentPage of
        ConfigPage ->
            Sub.none

        SimulationPage ->
            if model.simulationState.isPlaying then
               
                Time.every 500 Tick
            else
                Sub.none

-- GENERADOR DE GRILLA ALEATORIA
randomGridGenerator : Int -> Int -> Random.Generator Grid
randomGridGenerator width height =
    let
        -- Generador para una sola celda (20% viva, 80% muerta)
        cellGenerator =
            Random.weighted (20, Alive) [ (80, Dead) ]
        
        -- Generador para una fila (array de celdas)
        rowGenerator =
            Random.list width cellGenerator
                |> Random.map Array.fromList
    in
    -- Generador para la grilla (array de filas)
    Random.list height rowGenerator
        |> Random.map Array.fromList

    