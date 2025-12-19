module State.States exposing (..)

import Core.Automata exposing (nextGeneration)
import Core.Grid exposing (emptyGrid, toggleCell)
import Core.Rules exposing (parseRules)
import Core.Types exposing (..)
import Time

-- 1. MENSAJES
-- Definimos todo lo que puede ocurrir en la aplicación
type Msg
    = NoOp
    -- Acciones de Configuración
    | SetRuleInput String
    | ToggleConfigCell Position
    | StartSimulation
    -- Acciones de Simulación
    | Tick Time.Posix
    | TogglePlay
    | StepGeneration
    | StopSimulation

-- 2. INIT
-- Estado inicial de la aplicación
init : ( AppState, Cmd Msg )
init =
    let
        defaultWidth = 20
        defaultHeight = 20
        defaultRules = { birth = [3], survive = [2, 3] } -- Conway clásico
        defaultRuleStr = "B3/S23"
        
        initialConfig = 
            { grid = emptyGrid defaultWidth defaultHeight
            , rules = defaultRules
            , ruleInput = defaultRuleStr
            , width = defaultWidth
            , height = defaultHeight
            }

        initialSimulation =
            { grid = [] -- Se llenará al iniciar
            , rules = defaultRules
            , generation = 0
            , isPlaying = False
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
                    }
            in
            ( { model 
                | currentPage = SimulationPage
                , simulationState = newSimState 
              }
            , Cmd.none 
            )

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
                newGrid = nextGeneration sim.rules sim.grid
                newSim = 
                    { sim 
                    | grid = newGrid
                    , generation = sim.generation + 1
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