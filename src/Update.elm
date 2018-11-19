module Update exposing (Msg(..), update)

import Model exposing (Model)


type Msg
    = AssetsInputChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AssetsInputChanged text ->
            ( { model | assetsInput = text }, Cmd.none )
