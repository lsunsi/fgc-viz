module View exposing (view)

import Html exposing (Html, button, div, input, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Model exposing (Model)
import Update exposing (Msg(InterestDoubleClicked, InterestFormDateInput, InterestFormRateInput, InterestFormSubmitted))
import View.Helpers.Format as Format


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
    let
        control el =
            div [ class "control" ] [ el ]

        textInput k v m =
            input [ placeholder k, value v, type_ "text", class "input is-small", onInput m ] []
    in
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
            [ th [] [ text "Yield" ]
            , th [] [ text "Amount" ]
            , th [] [ text "Maturity" ]
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


view : Model -> Html Msg
view model =
    div []
        [ text "oie"
        , interestTable model
        , interestForm model
        , assetsTable model
        ]
