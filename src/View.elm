module View exposing (view)

import Browser exposing (Document)
import Html exposing (Html, text)
import Model exposing (Model)
import Update exposing (Msg)


view : Model -> Document Msg
view _ =
    { title = "fgc-viz"
    , body = [ text "oie mundo" ]
    }
