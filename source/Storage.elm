port module Storage exposing (decodeModel, encodeModel, retrieveModel, storeModel)

import Date
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Model exposing (Asset, Interest, Model)


port storeModel : Encode.Value -> Cmd msg


port retrieveModel : (Encode.Value -> msg) -> Sub msg


encodeDate : Date.Date -> Encode.Value
encodeDate =
    Date.toTime >> Encode.float


encodeInterest : Interest -> Encode.Value
encodeInterest { date, rate } =
    Encode.object
        [ ( "date", encodeDate date )
        , ( "rate", Encode.float rate )
        ]


encodeAsset : Asset -> Encode.Value
encodeAsset { maturity, amount, yield } =
    Encode.object
        [ ( "maturity", encodeDate maturity )
        , ( "amount", Encode.float amount )
        , ( "yield", Encode.float yield )
        ]


encodeModel : Model -> Encode.Value
encodeModel { interests, interestFormDate, interestFormRate, assets } =
    Encode.object
        [ ( "interests", Encode.list (List.map encodeInterest interests) )
        , ( "interestFormDate", Encode.string interestFormDate )
        , ( "interestFormRate", Encode.string interestFormRate )
        , ( "assets", Encode.list (List.map encodeAsset assets) )
        ]


decoderDate : Decode.Decoder Date.Date
decoderDate =
    Decode.map Date.fromTime Decode.float


decoderInterest : Decode.Decoder Interest
decoderInterest =
    decode Interest
        |> required "date" decoderDate
        |> required "rate" Decode.float


decoderAsset : Decode.Decoder Asset
decoderAsset =
    decode Asset
        |> required "maturity" decoderDate
        |> required "amount" Decode.float
        |> required "yield" Decode.float


decoderModel : Decode.Decoder Model
decoderModel =
    decode Model
        |> required "interests" (Decode.list decoderInterest)
        |> required "interestFormDate" Decode.string
        |> required "interestFormRate" Decode.string
        |> required "assets" (Decode.list decoderAsset)


decodeModel : Encode.Value -> Maybe Model
decodeModel value =
    Decode.decodeValue decoderModel value |> Result.toMaybe
