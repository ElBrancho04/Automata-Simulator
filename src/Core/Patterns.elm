module Core.Patterns exposing (..)

import Core.Types exposing (Position)

-- Convierte una representación en matriz de strings a lista de posiciones vivas
fromMatrix : List String -> List Position
fromMatrix rows =
    rows
        |> List.indexedMap
            (\r line ->
                line
                    |> String.toList
                    |> List.indexedMap Tuple.pair
                    |> List.filterMap
                        (\(c, ch) ->
                            if ch == 'O' then
                                Just ( r, c )
                            else
                                Nothing
                        )
            )
        |> List.concat

-- 1. EL PLANEADOR (GLIDER)
-- Se mueve en diagonal
glider : List Position
glider =
    [ (0, 1), (1, 2), (2, 0), (2, 1), (2, 2) ]

-- 2. NAVE LIGERA (LWSS)
-- Se mueve horizontalmente
lwss : List Position
lwss =
    [ (0, 1), (0, 4)
    , (1, 0)
    , (2, 0), (2, 4)
    , (3, 0), (3, 1), (3, 2), (3, 3)
    ]

-- 3. EL PULSAR (Oscilador periodo 3)
-- Es grande, requiere espacio
pulsar : List Position
pulsar =
    [ (2, 4), (2, 5), (2, 6), (2, 10), (2, 11), (2, 12)
    , (4, 2), (4, 7), (4, 9), (4, 14)
    , (5, 2), (5, 7), (5, 9), (5, 14)
    , (6, 2), (6, 7), (6, 9), (6, 14)
    , (7, 4), (7, 5), (7, 6), (7, 10), (7, 11), (7, 12)
    , (9, 4), (9, 5), (9, 6), (9, 10), (9, 11), (9, 12)
    , (10, 2), (10, 7), (10, 9), (10, 14)
    , (11, 2), (11, 7), (11, 9), (11, 14)
    , (12, 2), (12, 7), (12, 9), (12, 14)
    , (14, 4), (14, 5), (14, 6), (14, 10), (14, 11), (14, 12)
    ]


-- 4. DIAMOND RING (Oscilador período 2)
diamondRing : List Position
diamondRing =
    fromMatrix
        [ "......O......"
        , ".....O.O....."
        , "....O.O.O...."
        , "....O...O...."
        , "..OO..O..OO.."
        , ".O....O....O."
        , "O.O.OO.OO.O.O"
        , ".O....O....O."
        , "..OO..O..OO.."
        , "....O...O...."
        , "....O.O.O...."
        , ".....O.O....."
        , "......O......"
        ]


-- 5. DIEHARD (muere en ~130 generaciones)
diehard : List Position
diehard =
    fromMatrix
        [ "......O."
        , "OO......"
        , ".O...OOO"
        ]


-- 6. ACORN (crece mucho antes de estabilizar)
acorn : List Position
acorn =
    fromMatrix
        [ ".O....."
        , "...O..."
        , "OO..OOO"
        ]


-- 7. ANTS (patrón caótico)
ants : List Position
ants =
    fromMatrix
        [ "OO...OO...OO...OO...OO...OO...OO...OO...OO.."
        , "..OO...OO...OO...OO...OO...OO...OO...OO...OO"
        , "..OO...OO...OO...OO...OO...OO...OO...OO...OO"
        , "OO...OO...OO...OO...OO...OO...OO...OO...OO.."
        ]


-- 8. DINNER TABLE (Oscilador período 2)
dinnerTable : List Position
dinnerTable =
    fromMatrix
        [ ".O..........."
        , ".OOO.......OO"
        , "....O......O."
        , "...OO....O.O."
        , ".........OO.."
        , "............."
        , ".....OOO....."
        , ".....OOO....."
        , "..OO........."
        , ".O.O....OO..."
        , ".O......O...."
        , "OO.......OOO."
        , "...........O."
        ]


-- 9. GOSPER GLIDER GUN (Generador período ~30)
gosperGliderGun : List Position
gosperGliderGun =
    fromMatrix
        [ "........................O..........."
        , "......................O.O..........."
        , "............OO......OO............OO"
        , "...........O...O....OO............OO"
        , "OO........O.....O...OO.............."
        , "OO........O...O.OO....O.O..........."
        , "..........O.....O.......O..........."
        , "...........O...O...................."
        , "............OO......................"
        ]