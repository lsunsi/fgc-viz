module View exposing (view)

import Html exposing (Html, button, div, input, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model)
import Update exposing (Msg(InterestFormDateInput, InterestFormRateInput, InterestFormSubmitted))
import View.Helpers.Format as Format


interestTableHeader : Html msg
interestTableHeader =
    thead []
        [ tr []
            [ th [] [ text "Date" ]
            , th [] [ text "Rate" ]
            ]
        ]


interestTableBody : Model -> Html msg
interestTableBody { interests } =
    tbody []
        (List.map
            (\{ date, rate } ->
                tr []
                    [ td [] [ text (Format.date date) ]
                    , td [] [ text (Format.percentage rate) ]
                    ]
            )
            interests
        )


interestTable : Model -> Html msg
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


view : Model -> Html Msg
view model =
    div []
        [ text "oie"
        , interestTable model
        , interestForm model
        ]
