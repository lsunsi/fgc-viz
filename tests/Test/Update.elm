module Test.Update exposing (..)

import Date
import Date.Extra as Date
import Expect exposing (equal)
import Init exposing (init)
import Json.Encode as Encode
import Model exposing (Interest, Model)
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
                ]

        model =
            { interests = [ Interest (Date.fromCalendarDate 2018 Date.Jul 29) 1.23 ]
            , interestFormDate = "some-date"
            , interestFormRate = "some-rate"
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
                                [ Interest (Date.fromCalendarDate 2018 Date.Jan 10) 1.2
                                , Interest (Date.fromCalendarDate 2018 Date.Jan 12) 1.2
                                ]
                            , interestFormDate = ""
                            , interestFormRate = ""
                        }

                    model2 =
                        { model1
                            | interests =
                                [ Interest (Date.fromCalendarDate 2018 Date.Jan 10) 1.2
                                , Interest (Date.fromCalendarDate 2018 Date.Jan 11) 1.2
                                , Interest (Date.fromCalendarDate 2018 Date.Jan 12) 1.2
                                ]
                        }
                in
                model1
                    |> (update (InterestFormDateInput "2018-01-11") >> first)
                    |> (update (InterestFormRateInput "1.2") >> first)
                    |> update InterestFormSubmitted
                    |> equal (model2 ! [])
        , test "performs no operation when date input is invalid" <|
            \() ->
                let
                    model1 =
                        { model0 | interestFormDate = "invalid", interestFormRate = "1.2" }
                in
                model0
                    |> (update (InterestFormDateInput "invalid") >> first)
                    |> (update (InterestFormRateInput "1.2") >> first)
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
