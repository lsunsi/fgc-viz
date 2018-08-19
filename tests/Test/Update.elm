module Test.Update exposing (..)

import Date
import Date.Extra as Date
import Expect exposing (equal)
import Init exposing (init)
import Json.Encode as Encode
import Model exposing (Asset, Interest, Model)
import Storage exposing (encodeModel, storeModel)
import Test exposing (Test, describe, test)
import Tuple exposing (first)
import Update exposing (Msg(..), update)


model0 : Model
model0 =
    first init


modelRetrieved : Test
modelRetrieved =
    let
        value =
            Encode.object
                [ ( "interests"
                  , Encode.list
                        [ Encode.object
                            [ ( "date", Encode.float 1532833200000 ), ( "rate", Encode.float 1.23 ) ]
                        ]
                  )
                , ( "interestFormDate", Encode.string "some-date" )
                , ( "interestFormRate", Encode.string "some-rate" )
                , ( "assets"
                  , Encode.list
                        [ Encode.object
                            [ ( "maturity", Encode.float 1595991600000 )
                            , ( "amount", Encode.float 10000.0 )
                            , ( "yield", Encode.float 1.145 )
                            ]
                        ]
                  )
                , ( "assetFormMaturity", Encode.string "some-maturity" )
                , ( "assetFormAmount", Encode.string "some-amount" )
                , ( "assetFormYield", Encode.string "some-yield" )
                ]

        model =
            { interests = [ Interest (Date.fromCalendarDate 2018 Date.Jul 29) 1.23 ]
            , interestFormDate = "some-date"
            , interestFormRate = "some-rate"
            , assets = [ Asset (Date.fromCalendarDate 2020 Date.Jul 29) 10000.0 1.145 ]
            , assetFormMaturity = "some-maturity"
            , assetFormAmount = "some-amount"
            , assetFormYield = "some-yield"
            }
    in
    describe "ModelRetrived"
        [ test "replaces the whole model when the retrieved one is valid" <|
            \() ->
                model0
                    |> update (ModelRetrieved value)
                    |> equal (model ! [])
        , test "performs no operation if retrieved model is invalid" <|
            \() ->
                model0
                    |> update (ModelRetrieved (Encode.string "invalid"))
                    |> equal (model0 ! [])
        ]


interestFormDateInput : Test
interestFormDateInput =
    test "sets the interestFormDate field to message value" <|
        \() ->
            let
                model1 =
                    { model0 | interestFormDate = "some-date" }
            in
            model0
                |> update (InterestFormDateInput "some-date")
                |> equal (model1 ! [])


interestFormRateInput : Test
interestFormRateInput =
    test "sets the interestFormRate field to message value" <|
        \() ->
            let
                model1 =
                    { model0 | interestFormRate = "some-rate" }
            in
            model0
                |> update (InterestFormRateInput "some-rate")
                |> equal (model1 ! [])


interestFormSubmitted : Test
interestFormSubmitted =
    describe "InterestFormSubmitted"
        [ test "creates interest when inputs are valid" <|
            \() ->
                let
                    model1 =
                        { model0
                            | interests =
                                [ Interest (Date.fromCalendarDate 2018 Date.Jan 10) 1.205
                                , Interest (Date.fromCalendarDate 2018 Date.Jan 12) 1.205
                                ]
                            , interestFormDate = ""
                            , interestFormRate = ""
                        }

                    model2 =
                        { model1
                            | interests =
                                [ Interest (Date.fromCalendarDate 2018 Date.Jan 10) 1.205
                                , Interest (Date.fromCalendarDate 2018 Date.Jan 11) 1.205
                                , Interest (Date.fromCalendarDate 2018 Date.Jan 12) 1.205
                                ]
                        }
                in
                model1
                    |> (update (InterestFormDateInput "2018-01-11") >> first)
                    |> (update (InterestFormRateInput "120.5") >> first)
                    |> update InterestFormSubmitted
                    |> equal (model2 ! [ storeModel (encodeModel model2) ])
        , test "performs no operation when date input is invalid" <|
            \() ->
                let
                    model1 =
                        { model0 | interestFormDate = "invalid", interestFormRate = "120.5" }
                in
                model0
                    |> (update (InterestFormDateInput "invalid") >> first)
                    |> (update (InterestFormRateInput "120.5") >> first)
                    |> update InterestFormSubmitted
                    |> equal (model1 ! [])
        , test "performs no operation when rate input is invalid" <|
            \() ->
                let
                    model1 =
                        { model0 | interestFormDate = "2018-01-11", interestFormRate = "invalid" }
                in
                model0
                    |> (update (InterestFormDateInput "2018-01-11") >> first)
                    |> (update (InterestFormRateInput "invalid") >> first)
                    |> update InterestFormSubmitted
                    |> equal (model1 ! [])
        ]


interestDoubleClicked : Test
interestDoubleClicked =
    test "removes index from the interests list and persists model" <|
        \() ->
            let
                model1 =
                    { model0
                        | interests =
                            [ Interest (Date.fromCalendarDate 2018 Date.Jan 10) 1.2
                            , Interest (Date.fromCalendarDate 2019 Date.Feb 11) 1.3
                            , Interest (Date.fromCalendarDate 2020 Date.Mar 12) 1.4
                            ]
                    }

                model2 =
                    { model1
                        | interests =
                            [ Interest (Date.fromCalendarDate 2018 Date.Jan 10) 1.2
                            , Interest (Date.fromCalendarDate 2020 Date.Mar 12) 1.4
                            ]
                    }
            in
            model1
                |> update (InterestDoubleClicked 1)
                |> equal (model2 ! [ storeModel (encodeModel model2) ])


assetFormMaturityInput : Test
assetFormMaturityInput =
    test "sets the assetFormMaturity field to message value" <|
        \() ->
            let
                model1 =
                    { model0 | assetFormMaturity = "some-maturity" }
            in
            model0
                |> update (AssetFormMaturityInput "some-maturity")
                |> equal (model1 ! [])


assetFormAmountInput : Test
assetFormAmountInput =
    test "sets the assetFormAmount field to message value" <|
        \() ->
            let
                model1 =
                    { model0 | assetFormAmount = "some-amount" }
            in
            model0
                |> update (AssetFormAmountInput "some-amount")
                |> equal (model1 ! [])


assetFormYieldInput : Test
assetFormYieldInput =
    test "sets the assetFormYield field to message value" <|
        \() ->
            let
                model1 =
                    { model0 | assetFormYield = "some-yield" }
            in
            model0
                |> update (AssetFormYieldInput "some-yield")
                |> equal (model1 ! [])


assetFormSubmitted : Test
assetFormSubmitted =
    describe "AssetFormSubmitted"
        [ test "creates asset when inputs are valid" <|
            \() ->
                let
                    model1 =
                        { model0
                            | assets =
                                [ Asset (Date.fromCalendarDate 2018 Date.Jan 10) 123 1.205
                                , Asset (Date.fromCalendarDate 2018 Date.Jan 12) 123 1.205
                                ]
                            , assetFormMaturity = ""
                            , assetFormAmount = ""
                            , assetFormYield = ""
                        }

                    model2 =
                        { model1
                            | assets =
                                [ Asset (Date.fromCalendarDate 2018 Date.Jan 10) 123 1.205
                                , Asset (Date.fromCalendarDate 2018 Date.Jan 11) 123 1.205
                                , Asset (Date.fromCalendarDate 2018 Date.Jan 12) 123 1.205
                                ]
                        }
                in
                model1
                    |> (update (AssetFormMaturityInput "2018-01-11") >> first)
                    |> (update (AssetFormAmountInput "123") >> first)
                    |> (update (AssetFormYieldInput "120.5") >> first)
                    |> update AssetFormSubmitted
                    |> equal (model2 ! [ storeModel (encodeModel model2) ])
        , test "performs no operation when maturity input is invalid" <|
            \() ->
                let
                    model1 =
                        { model0
                            | assetFormMaturity = "invalid"
                            , assetFormAmount = "123"
                            , assetFormYield = "120.5"
                        }
                in
                model0
                    |> (update (AssetFormMaturityInput "invalid") >> first)
                    |> (update (AssetFormAmountInput "123") >> first)
                    |> (update (AssetFormYieldInput "120.5") >> first)
                    |> update AssetFormSubmitted
                    |> equal (model1 ! [])
        , test "performs no operation when amount input is invalid" <|
            \() ->
                let
                    model1 =
                        { model0
                            | assetFormMaturity = "2018-01-11"
                            , assetFormAmount = "invalid"
                            , assetFormYield = "120.5"
                        }
                in
                model0
                    |> (update (AssetFormMaturityInput "2018-01-11") >> first)
                    |> (update (AssetFormAmountInput "invalid") >> first)
                    |> (update (AssetFormYieldInput "120.5") >> first)
                    |> update AssetFormSubmitted
                    |> equal (model1 ! [])
        , test "performs no operation when yield input is invalid" <|
            \() ->
                let
                    model1 =
                        { model0
                            | assetFormMaturity = "2018-01-11"
                            , assetFormAmount = "123"
                            , assetFormYield = "invalid"
                        }
                in
                model0
                    |> (update (AssetFormMaturityInput "2018-01-11") >> first)
                    |> (update (AssetFormAmountInput "123") >> first)
                    |> (update (AssetFormYieldInput "invalid") >> first)
                    |> update AssetFormSubmitted
                    |> equal (model1 ! [])
        ]


assetDoubleClicked : Test
assetDoubleClicked =
    test "removes index from the assets list and persists model" <|
        \() ->
            let
                asset0 =
                    Asset (Date.fromCalendarDate 2018 Date.Jan 10) 12.12 1.2

                asset1 =
                    Asset (Date.fromCalendarDate 2019 Date.Feb 11) 13.13 1.3

                asset2 =
                    Asset (Date.fromCalendarDate 2020 Date.Mar 12) 14.14 1.4

                model1 =
                    { model0 | assets = [ asset0, asset1, asset2 ] }

                model2 =
                    { model1 | assets = [ asset0, asset2 ] }
            in
            model1
                |> update (AssetDoubleClicked 1)
                |> equal (model2 ! [ storeModel (encodeModel model2) ])
