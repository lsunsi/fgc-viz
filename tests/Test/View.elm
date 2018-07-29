module Test.View exposing (..)

import Init exposing (init)
import Test exposing (Test, test)
import Test.Html.Query exposing (fromHtml, has)
import Test.Html.Selector exposing (text)
import View exposing (view)


oie : Test
oie =
    test "shows oie on the screen" <|
        \() ->
            view init
                |> fromHtml
                |> has [ text "oie" ]
