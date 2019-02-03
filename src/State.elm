module State exposing (Msg, init, update)

import Model exposing (Model)


type Msg
    = NoOp


init : () -> ( Model, Cmd Msg )
init () =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
