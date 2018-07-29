module Test.Update exposing (..)

import Date
import Date.Extra as Date
import Expect exposing (equal)
import Init exposing (init)
import Json.Encode as Encode
import Model exposing (Interest, Model)
import Test exposing (Test, describe, test)
import Tuple exposing (first)
import Update exposing (Msg(ModelRetrieved), update)


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
