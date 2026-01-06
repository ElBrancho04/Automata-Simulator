module Core.PatternAnalysis exposing (analyzePattern)

import Array
import Core.Types exposing (..)
import Core.Grid exposing (countLiveCells, getSize)

-- Comparación básica de grillas
gridsEqual : Grid -> Grid -> Bool
gridsEqual g1 g2 = g1 == g2

-- Obtener celda con coordenadas ciclicas
getCyclicCell : Int -> Int -> Grid -> Cell
getCyclicCell row col grid =
    let
        (width, height) = getSize grid
        wrappedRow = modBy height row
        wrappedCol = modBy width col
    in
    grid
        |> Array.get wrappedRow
        |> Maybe.andThen (Array.get wrappedCol)
        |> Maybe.withDefault Dead

-- Verificar si grid2 es grid1 trasladada por (dx, dy)
isTranslatedBy : Grid -> Grid -> Int -> Int -> Bool
isTranslatedBy grid1 grid2 dx dy =
    let 
        liveCells1 =
            Array.toIndexedList grid1
                |> List.concatMap (\(r, row) ->
                    Array.toIndexedList row
                        |> List.filterMap (\(c, cell) ->
                            if cell == Alive then Just (r, c) else Nothing
                        )
                )
        
        allMatch =
            List.all
                (\(r, c) ->
                    getCyclicCell (r + dy) (c + dx) grid2 == Alive
                )
                liveCells1
    in
    allMatch

-- Detectar traslación entre dos grillas
detectTranslation : Grid -> Grid -> Maybe (Int, Int)
detectTranslation grid1 grid2 =
    let
        count1 = countLiveCells grid1
        count2 = countLiveCells grid2
    in
    if count1 /= count2 then
        Nothing
    else
        let
            -- Rangos de búsqueda para traslaciones típicas de naves
            translations = 
                [(-2,-2), (-2,-1), (-2,0), (-2,1), (-2,2),
                 (-1,-2), (-1,-1), (-1,0), (-1,1), (-1,2),
                 (0,-2), (0,-1),          (0,1), (0,2),
                 (1,-2), (1,-1), (1,0), (1,1), (1,2),
                 (2,-2), (2,-1), (2,0), (2,1), (2,2)]
        in
        List.foldl
            (\(dx, dy) found ->
                case found of
                    Just _ -> found
                    Nothing ->
                        if isTranslatedBy grid1 grid2 dx dy then
                            Just (dx, dy)
                        else
                            Nothing
            )
            Nothing
            translations

-- Detectar oscilación con posible traslación
detectOscillationWithTranslation : List Grid -> Maybe (Int, (Int, Int))
detectOscillationWithTranslation history =
    case history of
        current :: rest ->
            let
                currentCount = countLiveCells current
            in
            List.indexedMap (\idx grid -> (idx + 1, grid)) rest
                |> List.filterMap (\(idx, grid) ->
                    if countLiveCells grid /= currentCount then
                        Nothing
                    else if gridsEqual current grid then
                        Just (idx, (0, 0))
                    else
                        case detectTranslation current grid of
                            Just (dx, dy) -> Just (idx, (dx, dy))
                            Nothing -> Nothing
                )
                |> List.head
        _ -> Nothing

-- Función auxiliar para calcular promedio
average : List Int -> Float
average list =
    if List.isEmpty list then
        0
    else
        toFloat (List.sum list) / toFloat (List.length list)

-- Analizar tendencia de crecimiento/extinción
detectTrend : List Grid -> PatternType
detectTrend history =
    let
        counts = List.map countLiveCells history
        totalGenerations = List.length counts
        lastCount = 
            case List.head counts of
                Just c -> c
                Nothing -> 0
    in
    if totalGenerations < 8 then
        UnknownPattern
    
    else if lastCount == 0 then
        DyingPattern
    
    else if totalGenerations >= 10 then
        let
            last6 = List.take 6 counts
            
            last3 = List.take 3 last6
            previous3 = List.take 3 (List.drop 3 last6)
            
            avgLast3 = average last3
            avgPrevious3 = average previous3
            
            maxLast6 = Maybe.withDefault 0 (List.maximum last6)
            minLast6 = Maybe.withDefault 0 (List.minimum last6)
            
            rangeLast6 = maxLast6 - minLast6
            
            changes = 
                List.map2 (\a b -> abs (a - b)) 
                    (List.drop 1 last6) 
                    last6
            avgChange = average changes
            
            changePercent = 
                if avgPrevious3 > 0 then
                    ((avgLast3 - avgPrevious3) / avgPrevious3) * 100
                else
                    0
        in
        if avgLast3 > avgPrevious3 && 
           changePercent > 15 then
            GrowingPattern
        
        else if avgLast3 < avgPrevious3 && 
                changePercent < -15 then
            DyingPattern
        
        else if avgChange > avgLast3 * 0.3 &&
                toFloat rangeLast6 > avgLast3 * 0.6 then
            ChaoticPattern
        
        else if totalGenerations > 18 then
            ChaoticPattern
        
        else
            UnknownPattern
    
    else
        let
            firstHalf = List.drop (totalGenerations // 2) counts
            secondHalf = List.take (totalGenerations // 2) counts
            
            avgFirst = average firstHalf
            avgSecond = average secondHalf
        in
        if avgSecond > avgFirst * 1.5 then
            GrowingPattern
        else if avgSecond < avgFirst * 0.5 && avgSecond < 10 then
            DyingPattern
        else
            UnknownPattern

-- Función principal de análisis de patrones
analyzePattern : List Grid -> PatternType
analyzePattern history =
    case history of
        [] -> UnknownPattern
        [_] -> UnknownPattern
        current :: previous :: _ ->
            if gridsEqual current previous then
                StaticPattern
            else
                case detectOscillationWithTranslation history of
                    Just (period, (0, 0)) -> 
                        if period <= 20 then 
                            Oscillator period
                        else 
                            detectTrend history
                    
                    Just (period, (dx, dy)) ->
                        if (dx /= 0 || dy /= 0) && period <= 20 then
                            Spaceship (dx, dy) period
                        else
                            detectTrend history
                    
                    Nothing -> 
                        detectTrend history