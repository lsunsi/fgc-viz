module Test.View exposing (..)

import Date
import Date.Extra as Date
import Expect exposing (all)
import Init exposing (init)
import Model exposing (Interest, Model)
import Test exposing (Test, describe, test)
import Test.Html.Query exposing (find, fromHtml, has)
import Test.Html.Selector exposing (id, tag, text)
import Tuple exposing (first)
import View exposing (view)


state0 : Model
state0 =
    first init


oie : Test
oie =
    test "shows oie on the screen" <|
        \() ->
            view state0
                |> fromHtml
                |> has [ text "oie" ]


interestsTable : Test
interestsTable =
    let
        table =
            { state0 | interests = [ Interest (Date.fromCalendarDate 2018 Date.Jan 11) 1.2 ] }
                |> view
                |> fromHtml
                |> find [ id "interests-table" ]
    in
    describe "interests table"
        [ test "shows header with proper column names" <|
            \() ->
                table
                    |> find [ tag "thead" ]
                    |> all
                        [ has [ text "Date" ]
                        , has [ text "Rate" ]
                        ]
        , test "shows properly formatted interest on the body" <|
            \() ->
                table
                    |> find [ tag "tbody" ]
                    |> all
                        [ has [ text "120.00%" ]
                        , has [ text "2018-01-11" ]
                        ]
        ]
