module Core.Rules exposing (..)

import Core.Types exposing (Rules,Cell(..))

-- Parsear string de reglas en formato B/S
parseRules : String -> Maybe Rules
parseRules str =
    let
        cleanStr =
            String.toUpper (String.trim str)
        
        extractNumbers : String -> List Int
        extractNumbers s =
            s
                |> String.dropLeft 1
                |> String.toList
                |> List.filterMap (\c -> String.toInt (String.fromChar c))

    in
    case String.split "/" cleanStr of
        [ birthPart, survivePart ] ->
            if String.startsWith "B" birthPart && String.startsWith "S" survivePart then
                Just
                    { birth = extractNumbers birthPart
                    , survive = extractNumbers survivePart
                    }
            else
                Nothing
        
        _ ->
            Nothing

-- Validar si un string de reglas es válido
isValidRuleString : String -> Bool
isValidRuleString str =
    case parseRules str of
        Just _ -> True
        Nothing -> False

-- Aplicar reglas a una celda individual
applyRule : Rules -> Cell -> Int -> Cell
applyRule rules cell liveNeighbors =
    case cell of
        Alive ->
            if List.member liveNeighbors rules.survive then Alive else Dead

        Dead ->
            if List.member liveNeighbors rules.birth then Alive else Dead
