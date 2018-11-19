module Update exposing (Msg, update)

import Model exposing (Model)


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
