module Update exposing (Msg(..), update)

import Date.Extra as Date
import Json.Encode exposing (Value)
import List.Extra as List
import Model exposing (Interest, Model)
import Storage exposing (decodeModel, encodeModel, storeModel)


type Msg
    = ModelRetrieved Value
    | InterestFormDateInput String
    | InterestFormRateInput String
    | InterestFormSubmitted
    | InterestDoubleClicked Int


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
                    let
                        newModel =
                            { model
                                | interests = withInterest (Interest date (rate / 100))
                                , interestFormDate = ""
                                , interestFormRate = ""
                            }
                    in
                    newModel ! [ storeModel (encodeModel newModel) ]

                _ ->
                    model ! []

        InterestDoubleClicked i ->
            let
                newModel =
                    { model | interests = List.removeAt i model.interests }
            in
            newModel ! [ storeModel (encodeModel newModel) ]
