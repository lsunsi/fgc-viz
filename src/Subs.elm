module Subs exposing (subs)

import Model exposing (Model)
import Update exposing (Msg)


subs : Model -> Sub.Sub Msg
subs _ =
    Sub.none
