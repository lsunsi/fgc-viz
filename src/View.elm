module View exposing (view)

import Date
import Html exposing (Html, button, div, table, td, text, textarea, tr)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model)
import State exposing (Msg(..))


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ textarea [ onInput AssetsInputChanged ] []
            , button [ onClick AssetsInputSubmit ] [ text "go assets" ]
            ]
        , table []
            (List.map
                (\{ name, amount, yield, maturity } ->
                    tr []
                        [ td [] [ text name ]
                        , td [] [ text (String.fromFloat amount) ]
                        , td [] [ text (String.fromFloat yield) ]
                        , td [] [ text (Date.toIsoString maturity) ]
                        ]
                )
                model.assets
            )
        , table []
            (List.map
                (\{ date, rate } ->
                    tr []
                        [ td [] [ text (Date.toIsoString date) ]
                        , td [] [ text (String.fromFloat rate) ]
                        ]
                )
                model.rates
            )
        ]
