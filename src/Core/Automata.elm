module Core.Automata exposing (..)

import Core.Grid exposing (countLiveNeighbors)
import Core.Rules exposing (applyRule)
import Core.Types exposing (Grid, Rules)

nextGeneration : Rules -> Grid -> Grid
nextGeneration rules grid =
    List.indexedMap
        (\rowIndex row ->
            List.indexedMap
                (\colIndex cell ->
                    let
                        liveNeighbors = 
                            countLiveNeighbors (rowIndex, colIndex) grid
                    in
                    applyRule rules cell liveNeighbors
                )
                row
        )
        grid