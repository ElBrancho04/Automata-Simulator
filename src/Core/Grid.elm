module Core.Grid exposing (..)

import Array exposing (Array)
import Core.Types exposing (Cell(..),Grid,Position,BorderType(..))

-- Crear grilla vacía
emptyGrid : Int -> Int -> Grid
emptyGrid width height =
    Array.repeat height (Array.repeat width Dead)

-- Obtener celda en posición específica
getCell : Position -> Grid -> Cell
getCell (row, col) grid =
    grid
        |> Array.get row
        |> Maybe.andThen (Array.get col)
        |> Maybe.withDefault Dead

-- Contar celdas vivas en la grilla
countLiveCells : Grid -> Int
countLiveCells grid =
    grid
        |> Array.foldl
            (\row acc ->
                acc
                    + (row
                        |> Array.filter (\cell -> cell == Alive)
                        |> Array.length
                      )
            )
            0


-- Vecinos con borde toroidal (wrap-around)
getNeighborsToroidal : Position -> Grid -> List Cell
getNeighborsToroidal (row, col) grid =
    let
       
        (width, height) = getSize grid

        offsets =
            [ (-1,-1), (-1,0), (-1,1)
            , (0,-1),          (0,1)
            , (1,-1),  (1,0),  (1,1)
            ]
        
       
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

-- Vecinos con borde finito (fuera de límites = Dead)
getNeighborsFinite : Position -> Grid -> List Cell
getNeighborsFinite (row, col) grid =
    let
        (width, height) = getSize grid

        offsets =
            [ (-1,-1), (-1,0), (-1,1)
            , (0,-1),          (0,1)
            , (1,-1),  (1,0),  (1,1)
            ]
        
        getCellOrDead : (Int, Int) -> Cell
        getCellOrDead (r, c) =
            if r < 0 || r >= height || c < 0 || c >= width then
                Dead
            else
                getCell (r, c) grid
    in
    List.map (\(dr, dc) -> getCellOrDead (row + dr, col + dc)) offsets

-- Función principal parametrizada por tipo de borde
getNeighbors : BorderType -> Position -> Grid -> List Cell
getNeighbors borderType pos grid =
    case borderType of
        Toroidal -> getNeighborsToroidal pos grid
        Finite -> getNeighborsFinite pos grid

-- Contar vecinos vivos (parametrizado por tipo de borde)
countLiveNeighbors : BorderType -> Position -> Grid -> Int
countLiveNeighbors borderType pos grid =
    getNeighbors borderType pos grid
        |> List.filter (\cell -> cell == Alive)
        |> List.length

-- Toggle celda
toggleCell : Position -> Grid -> Grid
toggleCell (row, col) grid =
    case Array.get row grid of
        Nothing ->
            grid

        Just rowArr ->
            let
                newRow =
                    case Array.get col rowArr of
                        Nothing ->
                            rowArr

                        Just cell ->
                            Array.set col (if cell == Alive then Dead else Alive) rowArr
            in
            Array.set row newRow grid

-- Obtener tamaño de la grilla
getSize : Grid -> (Int, Int)
getSize grid =
    let
        height = Array.length grid
        width =
            grid
                |> Array.get 0
                |> Maybe.map Array.length
                |> Maybe.withDefault 0
    in
    (width, height)