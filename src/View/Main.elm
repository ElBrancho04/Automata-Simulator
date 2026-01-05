module View.Main exposing (main)

import Browser
import Core.Patterns
import Core.Rules exposing (isValidRuleString)
import Core.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import State.States exposing (Msg(..), init, subscriptions, update)

main : Program () AppState Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

view : AppState -> Html Msg
view model =
    div 
        [ style "font-family" "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif"
        , style "background" "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
        , style "min-height" "100vh"
        , style "padding" "30px 20px"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        ]
        [ div 
            [ style "background-color" "white"
            , style "border-radius" "16px"
            , style "box-shadow" "0 20px 60px rgba(0,0,0,0.3)"
            , style "padding" "40px"
            , style "max-width" "1200px"
            , style "width" "100%"
            ]
            [ h1 
                [ style "text-align" "center"
                , style "color" "#2d3748"
                , style "margin" "0 0 30px 0"
                , style "font-size" "2.5em"
                , style "font-weight" "700"
                ] 
                [ text "🧬 Juego de la Vida" ]
            , case model.currentPage of
                ConfigPage ->
                    viewConfigPage model.configState
                SimulationPage ->
                    viewSimulationPage model.simulationState
            ]
        ]

viewConfigPage : ConfigState -> Html Msg
viewConfigPage config =
    div [ style "display" "flex", style "flex-direction" "column", style "gap" "30px" ]
        [ div 
            [ style "text-align" "center"
            , style "padding" "20px"
            , style "background-color" "#f7fafc"
            , style "border-radius" "12px"
            , style "border" "2px solid #e2e8f0"
            ]
            [ h2 
                [ style "margin" "0 0 10px 0"
                , style "color" "#2d3748"
                , style "font-size" "1.5em"
                , style "font-weight" "600"
                ] 
                [ text "⚙️ Configuración" ]
            , p 
                [ style "margin" "0"
                , style "color" "#718096"
                , style "font-size" "0.95em"
                ] 
                [ text "Diseña tu patrón inicial haciendo clic en las celdas" ]
            ]
        
        , div 
            [ style "display" "flex"
            , style "gap" "20px"
            , style "flex-wrap" "wrap"
            , style "justify-content" "center"
            ]
            [ viewButton "🎲 Aleatorio" RandomizeGrid "primary"
            , viewButton "💫 Limpiar" ResetToConwayDefaults "secondary"
            ]
        
        , div 
            [ style "padding" "25px"
            , style "background-color" "#f7fafc"
            , style "border-radius" "12px"
            , style "border" "2px solid #e2e8f0"
            ]
            [ h3 
                [ style "margin" "0 0 15px 0"
                , style "color" "#2d3748"
                , style "font-size" "1.2em"
                , style "font-weight" "600"
                ] 
                [ text "📦 Patrones Predefinidos" ]
            , div 
                [ style "display" "flex"
                , style "gap" "12px"
                , style "flex-wrap" "wrap"
                , style "justify-content" "center"
                ]
                [ viewPatternButton "🚀 Glider" (LoadPattern Core.Patterns.glider)
                , viewPatternButton "🛸 Nave Ligera" (LoadPattern Core.Patterns.lwss)
                , viewPatternButton "✨ Pulsar" (LoadPattern Core.Patterns.pulsar)
                ]
            ]
        
        , div 
            [ style "display" "flex"
            , style "gap" "30px"
            , style "justify-content" "center"
            , style "align-items" "flex-start"
            , style "flex-wrap" "wrap"
            ]
            [ viewGrid config.grid True
            , div 
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "20px"
                , style "max-width" "300px"
                ]
                [ div 
                    [ style "padding" "25px"
                    , style "background-color" "#f7fafc"
                    , style "border-radius" "12px"
                    , style "border" "2px solid #e2e8f0"
                    ]
                    [ h3 
                        [ style "margin" "0 0 15px 0"
                        , style "color" "#2d3748"
                        , style "font-size" "1.2em"
                        , style "font-weight" "600"
                        ] 
                        [ text "🧮 Reglas de Evolución" ]
                    , div [ style "display" "flex", style "flex-direction" "column", style "gap" "12px" ]
                        [ label 
                            [ style "font-weight" "600"
                            , style "color" "#4a5568"
                            , style "font-size" "0.95em"
                            ] 
                            [ text "Formato B/S:" ]
                        , input
                            [ type_ "text"
                            , value config.ruleInput
                            , onInput SetRuleInput
                            , placeholder "Ej: B3/S23"
                            , style "padding" "12px 18px"
                            , style "border-radius" "8px"
                            , style "border" (if isValidRuleString config.ruleInput then "2px solid #48bb78" else "2px solid #f56565")
                            , style "font-size" "1.3em"
                            , style "font-family" "monospace"
                            , style "width" "100%"
                            , style "box-sizing" "border-box"
                            , style "transition" "all 0.2s"
                            ]
                            []
                        , if isValidRuleString config.ruleInput then
                            span 
                                [ style "color" "#48bb78"
                                , style "font-weight" "600"
                                , style "font-size" "0.9em"
                                ] 
                                [ text "✓ Reglas válidas" ]
                          else
                            span 
                                [ style "color" "#f56565"
                                , style "font-weight" "600"
                                , style "font-size" "0.9em"
                                ] 
                                [ text "✗ Formato inválido" ]
                        ]
                    ]
                
                , button
                    [ onClick StartSimulation
                    , disabled (not (isValidRuleString config.ruleInput))
                    , style "padding" "15px 30px"
                    , style "font-size" "1.1em"
                    , style "font-weight" "600"
                    , style "cursor" (if isValidRuleString config.ruleInput then "pointer" else "not-allowed")
                    , style "background" (if isValidRuleString config.ruleInput then "linear-gradient(135deg, #667eea 0%, #764ba2 100%)" else "#cbd5e0")
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "12px"
                    , style "box-shadow" (if isValidRuleString config.ruleInput then "0 4px 15px rgba(102, 126, 234, 0.4)" else "none")
                    , style "transition" "all 0.3s"
                    , style "width" "100%"
                    ]
                    [ text "▶️ Iniciar Simulación" ]
                ]
            ]
        ]

viewSimulationPage : SimulationState -> Html Msg
viewSimulationPage sim =
    div [ style "display" "flex", style "flex-direction" "column", style "gap" "25px" ]
        [ div 
            [ style "display" "flex"
            , style "justify-content" "space-between"
            , style "align-items" "center"
            , style "padding" "20px"
            , style "background-color" "#f7fafc"
            , style "border-radius" "12px"
            , style "border" "2px solid #e2e8f0"
            , style "flex-wrap" "wrap"
            , style "gap" "15px"
            ]
            [ div [ style "display" "flex", style "gap" "25px", style "align-items" "center", style "flex-wrap" "wrap" ]
                [ div []
                    [ div 
                        [ style "font-size" "0.85em"
                        , style "color" "#718096"
                        , style "font-weight" "600"
                        , style "margin-bottom" "5px"
                        ] 
                        [ text "GENERACIÓN" ]
                    , div 
                        [ style "font-size" "2em"
                        , style "color" "#2d3748"
                        , style "font-weight" "700"
                        ] 
                        [ text (String.fromInt sim.generation) ]
                    ]
                , div 
                    [ style "width" "2px"
                    , style "height" "50px"
                    , style "background-color" "#e2e8f0"
                    ] 
                    []
                , div []
                    [ div 
                        [ style "font-size" "0.85em"
                        , style "color" "#718096"
                        , style "font-weight" "600"
                        , style "margin-bottom" "5px"
                        ] 
                        [ text "ESTADO" ]
                    , div 
                        [ style "font-size" "1em"
                        , style "color" (if sim.isPlaying then "#48bb78" else "#ed8936")
                        , style "font-weight" "600"
                        ] 
                        [ text (if sim.isPlaying then "▶️ Ejecutando" else "⏸️ Pausado") ]
                    ]
                ]
            ]
        
        , div 
            [ style "display" "flex"
            , style "gap" "30px"
            , style "justify-content" "center"
            , style "align-items" "flex-start"
            , style "flex-wrap" "wrap"
            ]
            [ viewGrid sim.grid False
            , div 
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "20px"
                , style "max-width" "300px"
                ]
                [ if sim.analysisEnabled then
                    div 
                        [ style "padding" "20px"
                        , style "background" "linear-gradient(135deg, #667eea15 0%, #764ba215 100%)"
                        , style "border-radius" "12px"
                        , style "border" "2px solid #e2e8f0"
                        ]
                        [ div 
                            [ style "font-size" "0.85em"
                            , style "color" "#718096"
                            , style "font-weight" "600"
                            , style "margin-bottom" "8px"
                            ] 
                            [ text "🔬 PATRÓN DETECTADO" ]
                        , div 
                            [ style "font-size" "1.3em"
                            , style "color" "#2d3748"
                            , style "font-weight" "600"
                            ] 
                            [ text (patternToString sim.detectedPattern) ]
                        , if sim.generation < 2 then
                            div 
                                [ style "font-size" "0.85em"
                                , style "color" "#a0aec0"
                                , style "margin-top" "8px"
                                , style "font-style" "italic"
                                ] 
                                [ text "Analizando... necesita más generaciones" ]
                          else
                            text ""
                        ]
                  else
                    text ""
                
                , div 
                    [ style "display" "flex"
                    , style "flex-direction" "column"
                    , style "gap" "12px"
                    ]
                    [ button
                        [ onClick TogglePlay
                        , style "padding" "12px 24px"
                        , style "font-size" "1em"
                        , style "font-weight" "600"
                        , style "cursor" "pointer"
                        , style "background-color" (if sim.isPlaying then "#ed8936" else "#48bb78")
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "10px"
                        , style "box-shadow" "0 4px 12px rgba(0,0,0,0.15)"
                        , style "transition" "all 0.2s"
                        , style "width" "100%"
                        ]
                        [ text (if sim.isPlaying then "⏸️ Pausar" else "▶️ Reproducir") ]
                    
                    , button
                        [ onClick StepGeneration
                        , disabled sim.isPlaying
                        , style "padding" "12px 24px"
                        , style "font-size" "1em"
                        , style "font-weight" "600"
                        , style "cursor" (if sim.isPlaying then "not-allowed" else "pointer")
                        , style "background-color" (if sim.isPlaying then "#cbd5e0" else "#4299e1")
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "10px"
                        , style "box-shadow" (if sim.isPlaying then "none" else "0 4px 12px rgba(0,0,0,0.15)")
                        , style "transition" "all 0.2s"
                        , style "width" "100%"
                        ]
                        [ text "⏭️ Paso" ]
                    
                    , button
                        [ onClick StopSimulation
                        , style "padding" "12px 24px"
                        , style "font-size" "1em"
                        , style "font-weight" "600"
                        , style "cursor" "pointer"
                        , style "background-color" "#f56565"
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "10px"
                        , style "box-shadow" "0 4px 12px rgba(0,0,0,0.15)"
                        , style "transition" "all 0.2s"
                        , style "width" "100%"
                        ]
                        [ text "⏹️ Detener" ]
                    
                    , button 
                        [ onClick TogglePatternAnalysis
                        , style "padding" "10px 20px"
                        , style "font-size" "0.95em"
                        , style "font-weight" "600"
                        , style "cursor" "pointer"
                        , style "background-color" (if sim.analysisEnabled then "#805ad5" else "#a0aec0")
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "10px"
                        , style "box-shadow" "0 4px 12px rgba(0,0,0,0.15)"
                        , style "transition" "all 0.2s"
                        , style "width" "100%"
                        ] 
                        [ text (if sim.analysisEnabled then "🔬 Análisis Activado" else "💤 Análisis Desactivado") ]
                    ]
                ]
            ]
        ]

viewGrid : Grid -> Bool -> Html Msg
viewGrid grid isInteractive =
    div
        [ style "display" "inline-block"
        , style "border" "3px solid #2d3748"
        , style "border-radius" "8px"
        , style "overflow" "hidden"
        , style "box-shadow" "0 8px 20px rgba(0,0,0,0.15)"
        ]
        (List.indexedMap (viewRow isInteractive) grid)

viewRow : Bool -> Int -> List Cell -> Html Msg
viewRow isInteractive rowIndex cells =
    div [ style "display" "flex" ]
        (List.indexedMap (viewCell isInteractive rowIndex) cells)

viewCell : Bool -> Int -> Int -> Cell -> Html Msg
viewCell isInteractive rowIndex colIndex cell =
    div
        [ style "width" "20px"
        , style "height" "20px"
        , style "border" "1px solid #e2e8f0"
        , style "background-color" (if cell == Alive then "#2d3748" else "#ffffff")
        , style "cursor" (if isInteractive then "pointer" else "default")
        , style "transition" "all 0.15s"
        , if isInteractive then onClick (ToggleConfigCell (rowIndex, colIndex)) else style "" ""
        ]
        []

viewButton : String -> Msg -> String -> Html Msg
viewButton label msg buttonType =
    let
        bgColor = 
            case buttonType of
                "primary" -> "#4299e1"
                "secondary" -> "#718096"
                "danger" -> "#f56565"
                _ -> "#4299e1"
    in
    button
        [ onClick msg
        , style "padding" "12px 24px"
        , style "font-size" "1em"
        , style "font-weight" "600"
        , style "cursor" "pointer"
        , style "background-color" bgColor
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "10px"
        , style "box-shadow" "0 4px 12px rgba(0,0,0,0.15)"
        , style "transition" "all 0.2s"
        ]
        [ text label ]

viewPatternButton : String -> Msg -> Html Msg
viewPatternButton label msg =
    button
        [ onClick msg
        , style "padding" "10px 20px"
        , style "font-size" "0.95em"
        , style "font-weight" "600"
        , style "cursor" "pointer"
        , style "background-color" "#805ad5"
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "8px"
        , style "box-shadow" "0 3px 10px rgba(128, 90, 213, 0.3)"
        , style "transition" "all 0.2s"
        ]
        [ text label ]