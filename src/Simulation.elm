module Simulation exposing (simulate)

import Date exposing (Date)
import List.Extra as List
import Model exposing (Asset, DateRate)
import Time


chooseRate : Date -> List DateRate -> Float
chooseRate date rates =
    rates
        |> List.sortBy (.date >> Date.diff Date.Days date >> abs)
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


simulate : Date -> List Asset -> List DateRate -> List Float
simulate today initialAssets rates =
    let
        sortedInitialAssets =
            List.sortWith (\a1 a2 -> Date.compare a1.maturity a2.maturity) initialAssets

        initialDailyRate =
            List.head sortedInitialAssets
                |> Maybe.map (\{ maturity } -> (chooseRate maturity rates / 100 + 1) ^ (1.0 / 252) - 1)
                |> Maybe.withDefault 0.0

        dateStep date =
            Date.add Date.Days
                (if Date.weekday date == Time.Fri then
                    3

                 else
                    1
                )
                date

        correctAssets dailyRate =
            List.map (\asset -> { asset | amount = asset.amount * (dailyRate * asset.yield + 1) })

        assetsTotal =
            List.map .amount >> List.sum
    in
    List.unfoldr
        (\{ currentDate, currentDailyRate, currentAssets, accumulatedRate } ->
            Maybe.map
                (\_ ->
                    let
                        correctedAssets =
                            correctAssets currentDailyRate currentAssets

                        ( expiredAssets, activeAssets ) =
                            List.break
                                (\asset -> Date.compare asset.maturity currentDate == Basics.GT)
                                correctedAssets

                        nextDailyRate =
                            case ( expiredAssets, activeAssets ) of
                                ( [], _ ) ->
                                    currentDailyRate

                                ( _, [] ) ->
                                    currentDailyRate

                                ( _, { maturity } :: _ ) ->
                                    let
                                        dailyRate =
                                            (chooseRate maturity rates / 100 + 1) ^ (1.0 / 252) - 1

                                        nextDistance =
                                            toFloat (List.length (workdays currentDate maturity))

                                        totalDistance =
                                            toFloat (List.length (workdays today maturity))
                                    in
                                    ((dailyRate + 1) ^ totalDistance / (accumulatedRate + 1)) ^ (1 / nextDistance) - 1
                    in
                    ( assetsTotal correctedAssets
                    , { currentDate = dateStep currentDate
                      , currentDailyRate = nextDailyRate
                      , currentAssets = activeAssets
                      , accumulatedRate = (accumulatedRate + 1) * (currentDailyRate + 1) - 1
                      }
                    )
                )
                (List.head currentAssets)
        )
        { currentDate = today
        , currentDailyRate = initialDailyRate
        , currentAssets = sortedInitialAssets
        , accumulatedRate = 0.0
        }
