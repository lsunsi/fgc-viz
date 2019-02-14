module View exposing (view)

import Date exposing (Date)
import Html exposing (Html, button, div, table, td, text, textarea, tr)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import LineChart as Chart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
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

                    assetsCurves =
                        List.transpose (Simulation.simulate today selectedAssets model.rates)
                            |> List.map (List.indexedMap (toFloat >> Tuple.pair))
                in
                Chart.viewCustom
                    { x = Axis.default 700 "workdays" Tuple.first
                    , y = Axis.default 400 "amount" (Tuple.second >> .amount)
                    , container = Container.default "line-chart-1"
                    , interpolation = Interpolation.default
                    , intersection = Intersection.default
                    , legends = Legends.default
                    , events = Events.default
                    , junk = Junk.default
                    , grid = Grid.default
                    , area = Area.stacked 0.1
                    , line = Line.default
                    , dots = Dots.default
                    }
                    (List.map
                        (\curve ->
                            let
                                name =
                                    List.head curve
                                        |> Maybe.map (Tuple.second >> .name)
                                        |> Maybe.withDefault "none"
                            in
                            Chart.line Colors.teal Dots.none name curve
                        )
                        assetsCurves
                    )

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
