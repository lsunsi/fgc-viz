module Update exposing (Msg(..), update)

import Json.Encode exposing (Value)
import Model exposing (Model)
import Storage exposing (decodeModel)


type Msg
    = ModelRetrieved Value


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ModelRetrieved value ->
            Maybe.withDefault model (decodeModel value) ! []
