module Init exposing (init)

import Model exposing (Model)
import Update exposing (Msg)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { assetsInput = ""
      , assets = []
      }
    , Cmd.none
    )
