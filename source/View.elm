module View exposing (view)

import Html exposing (Html, button, div, input, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Model exposing (Model)
import Update exposing (Msg(..))
import View.Helpers.Format as Format


control : Html Msg -> Html Msg
control el =
    div [ class "control" ] [ el ]


textInput : String -> String -> (String -> Msg) -> Html Msg
textInput k v m =
    input [ placeholder k, value v, type_ "text", class "input is-small", onInput m ] []


interestTableHeader : Html msg
interestTableHeader =
    thead []
        [ tr []
            [ th [] [ text "Date" ]
            , th [] [ text "Rate" ]
            ]
        ]


interestTableBody : Model -> Html Msg
interestTableBody { interests } =
    tbody []
        (List.indexedMap
            (\i { date, rate } ->
                tr [ onDoubleClick (InterestDoubleClicked i) ]
                    [ td [] [ text (Format.date date) ]
                    , td [] [ text (Format.percentage rate) ]
                    ]
            )
            interests
        )


interestTable : Model -> Html Msg
interestTable model =
    table [ class "table", id "interests-table" ]
        [ interestTableHeader
        , interestTableBody model
        ]


interestForm : Model -> Html Msg
interestForm { interestFormDate, interestFormRate } =
    div [ id "interest-form" ]
        [ div [ class "field has-addons" ]
            [ control (textInput "Date" interestFormDate InterestFormDateInput)
            , control (textInput "Rate" interestFormRate InterestFormRateInput)
            , control (button [ class "button is-small", onClick InterestFormSubmitted ] [ text "Add" ])
            ]
        ]


assetsTableHeader : Html msg
assetsTableHeader =
    thead []
        [ tr []
            [ th [] [ text "Maturity" ]
            , th [] [ text "Amount" ]
            , th [] [ text "Yield" ]
            ]
        ]


assetsTableBody : Model -> Html msg
assetsTableBody { assets } =
    tbody []
        (List.indexedMap
            (\i { maturity, amount, yield } ->
                tr []
                    [ td [] [ text (Format.date maturity) ]
                    , td [] [ text (Format.number amount) ]
                    , td [] [ text (Format.percentage yield) ]
                    ]
            )
            assets
        )


assetsTable : Model -> Html Msg
assetsTable model =
    table [ class "table", id "assets-table" ]
        [ assetsTableHeader
        , assetsTableBody model
        ]


assetForm : Model -> Html Msg
assetForm { assetFormMaturity, assetFormAmount, assetFormYield } =
    div [ id "asset-form" ]
        [ div [ class "field has-addons" ]
            [ control (textInput "Maturity" assetFormMaturity AssetFormMaturityInput)
            , control (textInput "Amount" assetFormAmount AssetFormAmountInput)
            , control (textInput "Yield" assetFormYield AssetFormYieldInput)
            , control (button [ class "button is-small", onClick AssetFormSubmitted ] [ text "Add" ])
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ text "oie"
        , interestTable model
        , interestForm model
        , assetsTable model
        , assetForm model
        ]
