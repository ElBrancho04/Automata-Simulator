module View.Main exposing (main)

import Browser
import Core.Grid exposing (getSize)
import Core.Rules exposing (isValidRuleString)
import Core.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import State.States exposing (Msg(..), init, subscriptions, update)

-- 1. MAIN
-- Aquí conectamos el cerebro (State) con el cuerpo (View)
main : Program () AppState Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- 2. VIEW PRINCIPAL
-- Decide qué página mostrar según el estado
view : AppState -> Html Msg
view model =
    div [ style "font-family" "sans-serif", style "padding" "20px", style "display" "flex", style "flex-direction" "column", style "align-items" "center" ]
        [ h1 [] [ text "El Juego de la Vida (Elm)" ]
        , case model.currentPage of
            ConfigPage ->
                viewConfigPage model.configState

            SimulationPage ->
                viewSimulationPage model.simulationState
        ]

-- 3. VISTA CONFIGURACIÓN
viewConfigPage : ConfigState -> Html Msg
viewConfigPage config =
    div [ style "display" "flex", style "flex-direction" "column", style "align-items" "center", style "gap" "15px" ]
        [ h3 [] [ text "Configuración Inicial" ]
        , div []
            [ text "Dibuja el patrón inicial haciendo click en las celdas." ]
                , div [ style "display" "flex", style "gap" "10px", style "margin-bottom" "10px" ]
            [ button
                [ onClick RandomizeGrid
                , style "padding" "8px 15px"
                , style "cursor" "pointer"
                , style "background-color" "#2196F3" -- Azul
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "4px"
                ]
                [ text "🎲 Aleatorio" ]
            ]

        -- La Grilla (Interactiva)
        , viewGrid config.grid True

        -- Input de Reglas
        , div [ style "margin-top" "10px" ]
            [ label [ style "font-weight" "bold", style "margin-right" "10px" ] [ text "Reglas (Born/Survive):" ]
            , input
                [ type_ "text"
                , value config.ruleInput
                , onInput SetRuleInput
                , placeholder "Ej: B3/S23"
                , style "padding" "5px"
                , style "border" (if isValidRuleString config.ruleInput then "2px solid green" else "2px solid red")
                ]
                []
            ]
        , if isValidRuleString config.ruleInput then
            div [ style "color" "green", style "font-size" "0.8em" ] [ text "Reglas válidas" ]
          else
            div [ style "color" "red", style "font-size" "0.8em" ] [ text "Formato inválido. Usa B.../S..." ]

        -- Botón Iniciar
        , button
            [ onClick StartSimulation
            , style "padding" "10px 20px"
            , style "font-size" "16px"
            , style "cursor" "pointer"
            , style "background-color" "#4CAF50"
            , style "color" "white"
            , style "border" "none"
            , style "border-radius" "4px"
            , disabled (not (isValidRuleString config.ruleInput))
            ]
            [ text "Iniciar Simulación" ]
        ]

-- 4. VISTA SIMULACIÓN
viewSimulationPage : SimulationState -> Html Msg
viewSimulationPage sim =
    div [ style "display" "flex", style "flex-direction" "column", style "align-items" "center", style "gap" "15px" ]
        [ div [ style "font-size" "1.2em" ] 
            [ text ("Generación: " ++ String.fromInt sim.generation) ]
        
        -- La Grilla (Solo lectura)
        , viewGrid sim.grid False

        -- Controles
        , div [ style "display" "flex", style "gap" "10px" ]
            [ button
                [ onClick TogglePlay
                , style "padding" "10px 20px"
                , style "cursor" "pointer"
                ]
                [ text (if sim.isPlaying then "⏸ Pausa" else "▶ Reproducir") ]
            
            , button
                [ onClick StepGeneration
                , disabled sim.isPlaying
                , style "padding" "10px 20px"
                , style "cursor" "pointer"
                ]
                [ text "⏭ Paso Siguiente" ]
            
            , button
                [ onClick StopSimulation
                , style "padding" "10px 20px"
                , style "cursor" "pointer"
                , style "background-color" "#f44336"
                , style "color" "white"
                , style "border" "none"
                ]
                [ text "⏹ Detener / Configurar" ]
            ]
        , div [ style "font-size" "0.9em", style "color" "#666" ]
            [ text (if sim.isPlaying then "Simulando cada 0.5s..." else "Simulación pausada.") ]
        ]

-- 5. HELPER PARA DIBUJAR LA GRILLA
viewGrid : Grid -> Bool -> Html Msg
viewGrid grid isInteractive =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "border" "1px solid #333"
        ]
        (List.indexedMap (viewRow isInteractive) grid)

viewRow : Bool -> Int -> List Cell -> Html Msg
viewRow isInteractive rowIndex cells =
    div
        [ style "display" "flex" ]
        (List.indexedMap (viewCell isInteractive rowIndex) cells)

viewCell : Bool -> Int -> Int -> Cell -> Html Msg
viewCell isInteractive rowIndex colIndex cell =
    div
        [ style "width" "20px"
        , style "height" "20px"
        , style "border" "1px solid #eee"
        , style "background-color" (if cell == Alive then "black" else "white")
        , style "cursor" (if isInteractive then "pointer" else "default")
        
        -- Solo enviamos mensaje si es interactiva
        , if isInteractive then
            onClick (ToggleConfigCell (rowIndex, colIndex))
          else
            style "" "" -- No hace nada
        ]
        []