module View exposing (view)

import Date exposing (Date)
import Html exposing (Html, button, div, table, td, text, textarea, tr)
import Html.Events exposing (onClick, onInput)
import LineChart as Chart
import LineChart.Colors as Colors
import LineChart.Dots as Dots
import Model exposing (Model)
import Simulation
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
        , case ( model.today, List.head model.assets ) of
            ( Just today, Just asset ) ->
                let
                    curve =
                        Simulation.assetCurve today asset model.rates
                            |> List.indexedMap (toFloat >> Tuple.pair)
                in
                Chart.view Tuple.first Tuple.second [ Chart.line Colors.cyan Dots.none asset.name curve ]

            _ ->
                text "no simulation :("
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
