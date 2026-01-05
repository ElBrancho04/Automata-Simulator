module Core.Automata exposing (..)

import Array
import Core.Grid exposing (countLiveNeighbors)
import Core.Rules exposing (applyRule)
import Core.Types exposing (Grid, Rules, BorderType)

nextGeneration : BorderType -> Rules -> Grid -> Grid
nextGeneration borderType rules grid =
    Array.indexedMap
        (\rowIndex row ->
            Array.indexedMap
                (\colIndex cell ->
                    let
                        liveNeighbors =
                            countLiveNeighbors borderType (rowIndex, colIndex) grid
                    in
                    applyRule rules cell liveNeighbors
                )
                row
        )
        grid