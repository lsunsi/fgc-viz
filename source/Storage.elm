port module Storage exposing (decodeModel, encodeModel, retrieveModel, storeModel)

import Date
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Model exposing (Interest, Model)


port storeModel : Encode.Value -> Cmd msg


port retrieveModel : (Encode.Value -> msg) -> Sub msg


encodeInterest : Interest -> Encode.Value
encodeInterest { date, rate } =
    Encode.object
        [ ( "date", Encode.float (Date.toTime date) )
        , ( "rate", Encode.float rate )
        ]


encodeModel : Model -> Encode.Value
encodeModel { interests, interestFormDate, interestFormRate } =
    Encode.object
        [ ( "interests", Encode.list (List.map encodeInterest interests) )
        , ( "interestFormDate", Encode.string interestFormDate )
        , ( "interestFormRate", Encode.string interestFormRate )
        ]


decoderInterest : Decode.Decoder Interest
decoderInterest =
    decode Interest
        |> required "date" (Decode.map Date.fromTime Decode.float)
        |> required "rate" Decode.float


decoderModel : Decode.Decoder Model
decoderModel =
    decode Model
        |> required "interests" (Decode.list decoderInterest)
        |> required "interestFormDate" Decode.string
        |> required "interestFormRate" Decode.string


decodeModel : Encode.Value -> Maybe Model
decodeModel value =
    Decode.decodeValue decoderModel value |> Result.toMaybe
