module View exposing (view)

import Date exposing (Date)
import Html exposing (Html, button, div, table, td, text, textarea, tr)
import Html.Attributes as Attr
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
                (\asset ->
                    let
                        fontWeight =
                            model.selectedAsset
                                |> Maybe.andThen
                                    (\selectedAsset ->
                                        if selectedAsset == asset then
                                            Just "bold"

                                        else
                                            Nothing
                                    )
                                |> Maybe.withDefault "normal"
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
        , case ( model.today, model.selectedAsset ) of
            ( Just today, Just asset ) ->
                let
                    curve =
                        Simulation.assetCurve today asset model.rates
                            |> List.indexedMap (toFloat >> Tuple.pair)
                in
                Chart.view Tuple.first Tuple.second [ Chart.line Colors.cyan Dots.none asset.name curve ]

            _ ->
                text "no simulation :("
        , case model.today of
            Just today ->
                let
                    assetsCurve =
                        Simulation.assetsCurve today model.assets model.rates
                            |> List.indexedMap (toFloat >> Tuple.pair)

                    limitCurve =
                        List.repeat (List.length assetsCurve) 1000000.0
                            |> List.indexedMap (toFloat >> Tuple.pair)
                in
                Chart.view Tuple.first
                    Tuple.second
                    [ Chart.line Colors.teal Dots.none "group" assetsCurve
                    , Chart.line Colors.red Dots.none "limit" limitCurve
                    ]

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
