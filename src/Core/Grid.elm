module Core.Grid exposing (..)

import Core.Types exposing (Cell(..),Grid,Position)

-- Crear grilla vacía
emptyGrid : Int -> Int -> Grid
emptyGrid width height =
    List.repeat height (List.repeat width Dead)

-- Obtener celda en posición específica
getCell : Position -> Grid -> Cell
getCell (row, col) grid =
    let
        maybeRow = List.head (List.drop row grid)
    in
    case maybeRow of
        Just rowList ->
            case List.head (List.drop col rowList) of
                Just cell -> cell
                Nothing -> Dead
        Nothing -> Dead

-- Contar celdas vivas en la grilla
countLiveCells : Grid -> Int
countLiveCells grid =
    grid
        |> List.concat
        |> List.filter (\cell -> cell == Alive)
        |> List.length


getNeighbors : Position -> Grid -> List Cell
getNeighbors (row, col) grid =
    let
       
        (width, height) = getSize grid

        offsets = [(-1,-1), (-1,0), (-1,1),
                   (0,-1),          (0,1),
                   (1,-1),  (1,0),  (1,1)]
        
       
        positions = 
            List.map 
                (\(dr, dc) -> 
                    ( modBy height (row + dr)
                    , modBy width  (col + dc)
                    )
                ) 
                offsets
    in
    List.map (\pos -> getCell pos grid) positions
-- Contar vecinos vivos
countLiveNeighbors : Position -> Grid -> Int
countLiveNeighbors pos grid =
    getNeighbors pos grid
        |> List.filter (\cell -> cell == Alive)
        |> List.length

-- Toggle celda
toggleCell : Position -> Grid -> Grid
toggleCell (row, col) grid =
    let
        updateRow r rowList =
            if r == row then
                List.indexedMap
                    (\c cell ->
                        if c == col then
                            case cell of
                                Alive -> Dead
                                Dead -> Alive
                        else
                            cell
                    )
                    rowList
            else
                rowList
    in
    List.indexedMap updateRow grid

-- Obtener tamaño de la grilla
getSize : Grid -> (Int, Int)
getSize grid =
    let
        height = List.length grid
        width = 
            case List.head grid of
                Just firstRow -> List.length firstRow
                Nothing -> 0
    in
    (width, height)