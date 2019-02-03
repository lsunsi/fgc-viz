module State exposing (Msg, init, update)

import Api exposing (fetchRates)
import Http
import Model exposing (DateRate, Model)


type Msg
    = GotRates (Maybe (List DateRate))


init : () -> ( Model, Cmd Msg )
init () =
    ( { rates = []
      }
    , fetchRates GotRates
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRates (Just rates) ->
            ( { model | rates = rates }, Cmd.none )

        GotRates Nothing ->
            ( { model | rates = [] }, Cmd.none )
