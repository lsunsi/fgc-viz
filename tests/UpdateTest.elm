module UpdateTest exposing (assetsInputChanged, assetsLoadButtonPressed)

import Date
import Expect exposing (Expectation)
import Fuzz exposing (string)
import Init exposing (init)
import Model exposing (Asset, Model)
import Test exposing (Test, describe, fuzz, test)
import Time exposing (Month(..))
import Update exposing (Msg(..), update)


state0 =
    Tuple.first (init ())


assetsInputChanged : Test
assetsInputChanged =
    describe "AssetInputChanged"
        [ fuzz string "it sets model property accordingly" <|
            \str ->
                Expect.equal
                    ( { state0 | assetsInput = str }, Cmd.none )
                    (update (AssetsInputChanged str) { state0 | assetsInput = "" })
        ]


assetsLoadButtonPressed : Test
assetsLoadButtonPressed =
    describe "AssetsLoadButtonPressed"
        [ test "loads the assets and clears input" <|
            \() ->
                let
                    goodJson =
                        "[{\"assets\":[{\"amount\":\"12000.0\",\"liquidity\":3,\"name\":\"Médio\"},{\"amount\":\"12000.0\",\"maturity_date\":\"2020-11-09\",\"yield\":\"1.24\",\"name\":\"Maxima\"}]},{\"assets\":[{\"amount\":\"90000.0\",\"maturity_date\":\"2019-01-11\",\"yield\":\"1.15\",\"name\":\"Minima\"}]}]"

                    assets =
                        [ Asset "Minima" (Date.fromCalendarDate 2019 Jan 11) 90000.0 1.15
                        , Asset "Maxima" (Date.fromCalendarDate 2020 Nov 9) 12000.0 1.24
                        ]
                in
                Expect.equal
                    ( { state0 | assetsInput = "", assets = assets }, Cmd.none )
                    (update AssetsLoadButtonPressed { state0 | assetsInput = goodJson })
        ]
