module Update exposing (Msg(..), update)

import Date.Extra as Date
import Json.Encode exposing (Value)
import Model exposing (Interest, Model)
import Storage exposing (decodeModel)


type Msg
    = ModelRetrieved Value
    | InterestFormDateInput String
    | InterestFormRateInput String
    | InterestFormSubmitted


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ModelRetrieved value ->
            Maybe.withDefault model (decodeModel value) ! []

        InterestFormDateInput str ->
            { model | interestFormDate = str } ! []

        InterestFormRateInput str ->
            { model | interestFormRate = str } ! []

        InterestFormSubmitted ->
            let
                dateResult =
                    Date.fromIsoString model.interestFormDate

                rateResult =
                    String.toFloat model.interestFormRate

                withInterest interest =
                    List.sortWith
                        (\i1 i2 -> Date.compare i1.date i2.date)
                        (interest :: model.interests)
            in
            case ( dateResult, rateResult ) of
                ( Ok date, Ok rate ) ->
                    { model
                        | interests = withInterest (Interest date rate)
                        , interestFormDate = ""
                        , interestFormRate = ""
                    }
                        ! []

                _ ->
                    model ! []
