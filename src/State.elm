module State exposing (Msg(..), init, update)

import Api exposing (decodeAssets, fetchRates)
import Http
import Model exposing (DateRate, Model)


type Msg
    = GotRates (Maybe (List DateRate))
    | AssetsInputChanged String
    | AssetsInputSubmit


init : () -> ( Model, Cmd Msg )
init () =
    ( { rates = []
      , assets = []
      , assetsInput = ""
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

        AssetsInputChanged str ->
            ( { model | assetsInput = str }, Cmd.none )

        AssetsInputSubmit ->
            ( { model | assets = Result.withDefault [] (decodeAssets model.assetsInput) }, Cmd.none )
