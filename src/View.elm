module View exposing (view)

import Date exposing (Date)
import Html exposing (Html, button, div, table, td, text, textarea, tr)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import LineChart as Chart
import LineChart.Colors as Colors
import LineChart.Dots as Dots
import List.Extra as List
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
                (\( asset, selected ) ->
                    let
                        fontWeight =
                            if selected then
                                "bold"

                            else
                                "normal"
                    in
                    tr [ onClick (AssetSelected asset), Attr.style "font-weight" fontWeight ]
                        [ td [] [ text asset.name ]
                        , td [] [ text (String.fromFloat asset.amount) ]
                        , td [] [ text (String.fromFloat asset.yield) ]
                        , td [] [ text (Date.toIsoString asset.maturity) ]
                        ]
                )
                model.assets
            )
        , case model.today of
            Just today ->
                let
                    selectedAssets =
                        List.map Tuple.first (List.filter Tuple.second model.assets)

                    assetsCurve =
                        Simulation.simulate today selectedAssets model.rates
                            |> List.indexedMap (toFloat >> Tuple.pair)

                    limitCurve =
                        List.repeat (List.length assetsCurve) 1000000.0
                            |> List.indexedMap (toFloat >> Tuple.pair)
                in
                Chart.view Tuple.first
                    Tuple.second
                    [ Chart.line Colors.teal Dots.none "portfolio" assetsCurve ]

            Nothing ->
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
