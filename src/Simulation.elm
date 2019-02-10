module Simulation exposing (assetCurve)

import Date exposing (Date)
import Model exposing (Asset, DateRate)
import Time


chooseRate : Asset -> List DateRate -> Float
chooseRate asset rates =
    rates
        |> List.sortBy (.date >> Date.diff Date.Days asset.maturity >> abs)
        |> List.head
        |> Maybe.map .rate
        |> Maybe.withDefault 0.0


workdays : Date -> Date -> List Date
workdays start end =
    List.filter
        (\date ->
            let
                weekday =
                    Date.weekday date
            in
            weekday /= Time.Sat && weekday /= Time.Sun
        )
        (Date.range Date.Day 1 start end)


assetCurve : Date -> Asset -> List DateRate -> List Float
assetCurve today asset rates =
    let
        dailyRate =
            (chooseRate asset rates / 100 + 1) ^ (1.0 / 252) - 1
    in
    List.reverse
        (List.foldr
            (\_ acc ->
                case List.head acc of
                    Just amount ->
                        (amount * (dailyRate * asset.yield + 1)) :: acc

                    Nothing ->
                        [ asset.amount ]
            )
            []
            (workdays today asset.maturity)
        )
