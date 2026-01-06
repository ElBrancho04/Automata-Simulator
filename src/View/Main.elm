module View.Main exposing (main)

import Array
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
            , div [ style "display" "flex", style "flex-direction" "column", style "gap" "16px" ]
                [ patternGroup "🚀 Naves" 
                    [ viewPatternButtonWithTitle "🚀 Glider" "Nave pequeña (diagonal)" (LoadPattern Core.Patterns.glider)
                    , viewPatternButtonWithTitle "🛸 LWSS" "Nave ligera (horizontal)" (LoadPattern Core.Patterns.lwss)
                    ]

                , patternGroup "🔁 Osciladores"
                    [ viewPatternButtonWithTitle "✨ Pulsar" "Oscilador período 3" (LoadPattern Core.Patterns.pulsar)
                    , viewPatternButtonWithTitle "💠 Diamond Ring" "Oscilador período 2" (LoadPattern Core.Patterns.diamondRing)
                    , viewPatternButtonWithTitle "🍽️ Dinner Table" "Oscilador período 2" (LoadPattern Core.Patterns.dinnerTable)
                    ]

                , patternGroup "🌱 Crecimiento / Longevos"
                    [ viewPatternButtonWithTitle "🌰 Acorn" "Explosión grande (~5200 gen)" (LoadPattern Core.Patterns.acorn)
                    , viewPatternButtonWithTitle "� Diehard" "Muere cerca de 130 gen" (LoadPattern Core.Patterns.diehard)
                    ]

                , patternGroup "🌀 Caóticos / Generadores"
                    [ viewPatternButtonWithTitle "🐜 Ants" "Patrón caótico" (LoadPattern Core.Patterns.ants)
                    , viewPatternButtonWithTitle "🔫 Gosper Gun" "Generador de planeadores (per. ~30)" (LoadPattern Core.Patterns.gosperGliderGun)
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
            [ -- Columna izquierda: Zoom + Grilla
              div 
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "15px"
                , style "align-items" "center"
                ]
                [ -- Control de zoom encima de la grilla
                  div 
                    [ style "display" "flex"
                    , style "gap" "10px"
                    , style "align-items" "center"
                    , style "padding" "10px 20px"
                    , style "background-color" "#f7fafc"
                    , style "border-radius" "8px"
                    , style "border" "2px solid #e2e8f0"
                    ]
                    [ span 
                        [ style "font-weight" "600"
                        , style "color" "#4a5568"
                        , style "font-size" "0.9em"
                        ] 
                        [ text "🔍 Zoom:" ]
                    , button
                        [ onClick (SetCellSize (config.cellSize - 5))
                        , disabled (config.cellSize <= 5)
                        , style "padding" "6px 12px"
                        , style "font-size" "1.1em"
                        , style "font-weight" "600"
                        , style "cursor" (if config.cellSize <= 5 then "not-allowed" else "pointer")
                        , style "background-color" (if config.cellSize <= 5 then "#cbd5e0" else "#4299e1")
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "6px"
                        ]
                        [ text "-" ]
                    , span 
                        [ style "font-weight" "600"
                        , style "color" "#2d3748"
                        , style "min-width" "50px"
                        , style "text-align" "center"
                        ] 
                        [ text (String.fromInt config.cellSize ++ "px") ]
                    , button
                        [ onClick (SetCellSize (config.cellSize + 5))
                        , disabled (config.cellSize >= 40)
                        , style "padding" "6px 12px"
                        , style "font-size" "1.1em"
                        , style "font-weight" "600"
                        , style "cursor" (if config.cellSize >= 40 then "not-allowed" else "pointer")
                        , style "background-color" (if config.cellSize >= 40 then "#cbd5e0" else "#4299e1")
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "6px"
                        ]
                        [ text "+" ]
                    ]
                -- Panel de la grilla con scroll horizontal y vertical
                , div 
                    [ style "width" "650px"
                    , style "height" "650px"
                    , style "overflow" "auto"
                    , style "border" "2px solid #e2e8f0"
                    , style "border-radius" "8px"
                    , style "background-color" "#f7fafc"
                    ]
                    [ div 
                        [ style "display" "inline-block"
                        , style "min-width" "100%"
                        , style "min-height" "100%"
                        ]
                        [ viewGridWithSize config.grid True config.cellSize ]
                    ]
                ]
            , div 
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "20px"
                , style "max-width" "300px"
                ]
                [ -- Control de tamaño de grilla
                  div 
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
                        [ text "📐 Tamaño de Grilla" ]
                    , span 
                        [ style "display" "block"
                        , style "color" "#a0aec0"
                        , style "font-size" "0.85em"
                        , style "margin-bottom" "12px"
                        ]
                        [ text ("Actual: " ++ String.fromInt config.width ++ " × " ++ String.fromInt config.height) ]
                    , div [ style "display" "flex", style "gap" "15px", style "align-items" "center", style "flex-wrap" "wrap" ]
                        [ div []
                            [ label 
                                [ style "font-weight" "600"
                                , style "color" "#4a5568"
                                , style "font-size" "0.9em"
                                ] 
                                [ text "Ancho:" ]
                            , input
                                [ type_ "number"
                                , Html.Attributes.min "1"
                                , Html.Attributes.max "100"
                                , value config.widthInput
                                , onInput SetWidthInput
                                , style "width" "70px"
                                , style "padding" "8px"
                                , style "border-radius" "6px"
                                , style "border" "2px solid #e2e8f0"
                                , style "font-size" "1em"
                                , style "margin-left" "8px"
                                ]
                                []
                            ]
                        , div []
                            [ label 
                                [ style "font-weight" "600"
                                , style "color" "#4a5568"
                                , style "font-size" "0.9em"
                                ] 
                                [ text "Alto:" ]
                            , input
                                [ type_ "number"
                                , Html.Attributes.min "1"
                                , Html.Attributes.max "100"
                                , value config.heightInput
                                , onInput SetHeightInput
                                , style "width" "70px"
                                , style "padding" "8px"
                                , style "border-radius" "6px"
                                , style "border" "2px solid #e2e8f0"
                                , style "font-size" "1em"
                                , style "margin-left" "8px"
                                ]
                                []
                            ]
                        ]
                    , button
                        [ onClick ApplyGridSize
                        , style "margin-top" "15px"
                        , style "padding" "10px 20px"
                        , style "font-size" "0.95em"
                        , style "font-weight" "600"
                        , style "cursor" "pointer"
                        , style "background-color" "#48bb78"
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "8px"
                        , style "width" "100%"
                        ]
                        [ text "✓ Aplicar Tamaño" ]
                    ]
                
                -- Control de tipo de borde
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
                        [ text "🔲 Tipo de Borde" ]
                    , div [ style "display" "flex", style "gap" "10px" ]
                        [ button
                            [ onClick (SetBorderType Toroidal)
                            , style "padding" "10px 16px"
                            , style "font-size" "0.95em"
                            , style "font-weight" "600"
                            , style "cursor" "pointer"
                            , style "background-color" (if config.borderType == Toroidal then "#4299e1" else "#e2e8f0")
                            , style "color" (if config.borderType == Toroidal then "white" else "#4a5568")
                            , style "border" "none"
                            , style "border-radius" "8px"
                            , style "transition" "all 0.2s"
                            ]
                            [ text "🌐 Toroidal" ]
                        , button
                            [ onClick (SetBorderType Finite)
                            , style "padding" "10px 16px"
                            , style "font-size" "0.95em"
                            , style "font-weight" "600"
                            , style "cursor" "pointer"
                            , style "background-color" (if config.borderType == Finite then "#4299e1" else "#e2e8f0")
                            , style "color" (if config.borderType == Finite then "white" else "#4a5568")
                            , style "border" "none"
                            , style "border-radius" "8px"
                            , style "transition" "all 0.2s"
                            ]
                            [ text "📦 Finito" ]
                        ]
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
                        [ text "BORDE" ]
                    , div 
                        [ style "font-size" "1em"
                        , style "color" "#2d3748"
                        , style "font-weight" "600"
                        ] 
                        [ text (if sim.borderType == Toroidal then "🌐 Toroidal" else "📦 Finito") ]
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
            [ -- Panel de la grilla con scroll horizontal y vertical
              div 
                                [ style "width" "650px"
                                , style "height" "650px"
                , style "overflow" "auto"
                , style "border" "2px solid #e2e8f0"
                , style "border-radius" "8px"
                , style "background-color" "#f7fafc"
                ]
                [ div 
                    [ style "display" "inline-block"
                    , style "min-width" "100%"
                    , style "min-height" "100%"
                    ]
                    [ viewGridWithSize sim.grid False sim.cellSize ]
                ]
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

viewGridWithSize : Grid -> Bool -> Int -> Html Msg
viewGridWithSize grid isInteractive cellSize =
    div
        [ style "display" "inline-block"
        , style "border" "3px solid #2d3748"
        , style "border-radius" "8px"
        , style "overflow" "hidden"
        , style "box-shadow" "0 8px 20px rgba(0,0,0,0.15)"
        ]
        (grid |> Array.toList |> List.indexedMap (viewRowWithSize isInteractive cellSize))

viewRowWithSize : Bool -> Int -> Int -> Array.Array Cell -> Html Msg
viewRowWithSize isInteractive cellSize rowIndex cells =
    div [ style "display" "flex" ]
        (cells |> Array.toList |> List.indexedMap (viewCellWithSize isInteractive cellSize rowIndex))

viewCellWithSize : Bool -> Int -> Int -> Int -> Cell -> Html Msg
viewCellWithSize isInteractive cellSize rowIndex colIndex cell =
    let
        sizeStr = String.fromInt cellSize ++ "px"
    in
    div
        [ style "width" sizeStr
        , style "height" sizeStr
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

patternGroup : String -> List (Html Msg) -> Html Msg
patternGroup titleLabel buttons =
    div []
        [ div
            [ style "font-size" "0.9em"
            , style "font-weight" "700"
            , style "color" "#4a5568"
            , style "margin" "0 0 8px 0"
            ]
            [ text titleLabel ]
        , div
            [ style "display" "flex"
            , style "gap" "10px"
            , style "flex-wrap" "wrap"
            , style "justify-content" "center"
            ]
            buttons
        ]


viewPatternButtonWithTitle : String -> String -> Msg -> Html Msg
viewPatternButtonWithTitle label tooltip msg =
    button
        [ onClick msg
        , title tooltip
        , style "padding" "10px 16px"
        , style "font-size" "0.92em"
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