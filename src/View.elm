module View exposing (view)

import Html exposing (Html, text)
import Model exposing (Model)
import State exposing (Msg)


view : Model -> Html Msg
view _ =
    text "oie mundo"
