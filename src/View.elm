module View exposing (view)

import Array
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (onClick, onInput, onSubmit)
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
import Model exposing (AssetSortCriteria(..), Model)
import Simulation
import State exposing (Msg(..))


controlsView : Model -> Html Msg
controlsView model =
    div [ class "column is-one-quarter" ]
        [ div [ class "box" ]
            [ div [ class "title is-4" ] [ text "Assets" ]
            , form [ onSubmit AssetsInputSubmit ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control is-expanded" ]
                        [ input [ onInput AssetsInputChanged, class "input" ] []
                        ]
                    , div [ class "control" ]
                        [ button [ class "button" ] [ text "load" ]
                        ]
                    ]
                ]
            , table [ class "table is-fullwidth is-hoverable" ]
                [ thead []
                    [ tr []
                        [ th
                            [ onClick (AssetsHeaderSelected NameSort)
                            , style "cursor" "pointer"
                            ]
                            [ text "name" ]
                        , th
                            [ onClick (AssetsHeaderSelected MaturitySort)
                            , class "has-text-centered"
                            , style "cursor" "pointer"
                            ]
                            [ text "maturity" ]
                        , th
                            [ onClick (AssetsHeaderSelected YieldSort)
                            , class "has-text-right"
                            , style "cursor" "pointer"
                            ]
                            [ text "yield" ]
                        , th
                            [ onClick (AssetsHeaderSelected AmountSort)
                            , class "has-text-right"
                            , style "cursor" "pointer"
                            ]
                            [ text "amount" ]
                        ]
                    ]
                , tbody []
                    (List.map
                        (\( asset, selected ) ->
                            tr
                                [ onClick (AssetSelected asset)
                                , classList [ ( "is-selected", selected ) ]
                                , style "cursor" "pointer"
                                ]
                                [ td [] [ text asset.name ]
                                , td [ class "has-text-centered" ] [ text (Date.toIsoString asset.maturity) ]
                                , td [ class "has-text-right" ] [ text (String.fromFloat asset.yield) ]
                                , td [ class "has-text-right" ] [ text (String.fromFloat asset.amount) ]
                                ]
                        )
                        model.assets
                    )
                ]
            , table [ class "table is-fullwidth" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "date" ]
                        , th [ class "has-text-right" ] [ text "yearly rate" ]
                        ]
                    ]
                , tbody []
                    (List.map
                        (\{ date, rate } ->
                            tr []
                                [ td [] [ text (Date.toIsoString date) ]
                                , td [ class "has-text-right" ] [ text (String.fromFloat rate) ]
                                ]
                        )
                        model.rates
                    )
                ]
            ]
        ]


chartView : Model -> Html Msg
chartView model =
    div [ class "column" ]
        [ case model.today of
            Just today ->
                let
                    selectedAssets =
                        List.map Tuple.first (List.filter Tuple.second model.assets)

                    assetsCurves =
                        List.transpose (Simulation.simulate today selectedAssets model.rates)
                            |> List.map (List.indexedMap Tuple.pair)

                    colors =
                        Array.fromList
                            [ Colors.pink
                            , Colors.blue
                            , Colors.gold
                            , Colors.red
                            , Colors.green
                            , Colors.cyan
                            , Colors.teal
                            , Colors.purple
                            , Colors.rust
                            ]
                in
                Chart.viewCustom
                    { x = Axis.default 1400 "workdays" (Tuple.first >> toFloat)
                    , y = Axis.default 800 "amount" (Tuple.second >> .amount)
                    , container =
                        Container.custom
                            { id = "line-chart-1"
                            , size = Container.relative
                            , attributesSvg = []
                            , attributesHtml = []
                            , margin = Container.Margin 5 90 25 90
                            }
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
                    (List.indexedMap
                        (\i curve ->
                            let
                                name =
                                    List.head curve
                                        |> Maybe.map (Tuple.second >> .name)
                                        |> Maybe.withDefault "none"

                                color =
                                    Array.get (remainderBy (Array.length colors) i) colors
                                        |> Maybe.withDefault Colors.black
                            in
                            Chart.line color Dots.none name curve
                        )
                        assetsCurves
                    )

            Nothing ->
                text "no simulation :("
        ]


view : Model -> Html Msg
view model =
    section
        [ class "section" ]
        [ div [ class "columns" ] [ controlsView model, chartView model ]
        ]
