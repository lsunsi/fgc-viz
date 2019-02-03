module View exposing (view)

import Date
import Html exposing (Html, div, table, td, text, tr)
import Model exposing (Model)
import State exposing (Msg)


view : Model -> Html Msg
view model =
    table []
        (List.map
            (\{ date, rate } ->
                tr []
                    [ td [] [ text (Date.toIsoString date) ]
                    , td [] [ text (String.fromFloat rate) ]
                    ]
            )
            model.rates
        )
