module View exposing (view)

import Html exposing (Html, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, id)
import Model exposing (Model)
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


view : Model -> Html msg
view model =
    div []
        [ text "oie"
        , interestTable model
        ]
