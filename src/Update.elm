module Update exposing (Msg(..), update)

import Date
import Decoders exposing (assetsDecoder)
import Json.Decode exposing (decodeString)
import Model exposing (Model)


type Msg
    = AssetsInputChanged String
    | AssetsLoadButtonPressed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AssetsInputChanged text ->
            ( { model | assetsInput = text }, Cmd.none )

        AssetsLoadButtonPressed ->
            case decodeString assetsDecoder model.assetsInput of
                Ok assets ->
                    ( { model
                        | assetsInput = ""
                        , assets =
                            List.sortWith
                                (\a1 a2 -> Date.compare a1.maturity a2.maturity)
                                assets
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )
