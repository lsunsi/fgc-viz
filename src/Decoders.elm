module Decoders exposing (assetsDecoder)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, fail, succeed)
import Json.Decode.Pipeline exposing (required)
import List.Extra as List
import Model exposing (Asset)


decodeMaybe : Maybe a -> Decoder a
decodeMaybe =
    Maybe.map succeed
        >> Maybe.withDefault (fail ":(")


decodeResult : Result e a -> Decoder a
decodeResult =
    Result.toMaybe >> decodeMaybe


dateDecoder : Decoder Date
dateDecoder =
    Decode.andThen
        (Date.fromIsoString >> decodeResult)
        Decode.string


decimalDecoder : Decoder Float
decimalDecoder =
    Decode.andThen
        (String.toFloat >> decodeMaybe)
        Decode.string


assetDecoder : Decoder Asset
assetDecoder =
    succeed Asset
        |> required "name" Decode.string
        |> required "maturity_date" dateDecoder
        |> required "amount" decimalDecoder
        |> required "yield" decimalDecoder


assetsDecoder : Decoder (List Asset)
assetsDecoder =
    assetDecoder
        |> Decode.maybe
        |> Decode.list
        |> Decode.field "assets"
        |> Decode.list
        |> Decode.map (List.concatMap (List.filterMap identity))
