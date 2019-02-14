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


simulate : Date -> List Asset -> List DateRate -> List (List Asset)
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

        expireAssets date =
            List.map
                (\asset ->
                    { asset
                        | amount =
                            if Date.compare asset.maturity date == Basics.LT then
                                0.0

                            else
                                asset.amount
                    }
                )

        assetsTotal =
            List.map .amount >> List.sum
    in
    List.unfoldr
        (\{ currentDate, currentDailyRate, currentAssets, accumulatedRate } ->
            if assetsTotal currentAssets == 0.0 then
                Nothing

            else
                let
                    expiredAssets =
                        expireAssets currentDate currentAssets

                    correctedAssets =
                        correctAssets currentDailyRate expiredAssets

                    nextDailyRate =
                        if expiredAssets == currentAssets then
                            currentDailyRate

                        else
                            List.find (.amount >> (/=) 0) expiredAssets
                                |> Maybe.map
                                    (\{ maturity } ->
                                        let
                                            dailyRate =
                                                (chooseRate maturity rates / 100 + 1) ^ (1.0 / 252) - 1

                                            nextDistance =
                                                toFloat (List.length (workdays currentDate maturity))

                                            totalDistance =
                                                toFloat (List.length (workdays today maturity))
                                        in
                                        ((dailyRate + 1) ^ totalDistance / (accumulatedRate + 1)) ^ (1 / nextDistance) - 1
                                    )
                                |> Maybe.withDefault currentDailyRate
                in
                Just
                    ( correctedAssets
                    , { currentDate = dateStep currentDate
                      , currentDailyRate = nextDailyRate
                      , currentAssets = correctedAssets
                      , accumulatedRate = (accumulatedRate + 1) * (currentDailyRate + 1) - 1
                      }
                    )
        )
        { currentDate = today
        , currentDailyRate = initialDailyRate
        , currentAssets = sortedInitialAssets
        , accumulatedRate = 0.0
        }
