module State exposing (Msg(..), init, update)

import Api exposing (decodeAssets, fetchRates)
import Date exposing (Date)
import List.Extra as List
import Model exposing (Asset, AssetSortCriteria(..), DateRate, Model)


type Msg
    = GotRates (Maybe ( Date, List DateRate ))
    | AssetsInputChanged String
    | AssetsInputSubmit
    | AssetSelected Asset
    | AssetsHeaderSelected AssetSortCriteria


init : () -> ( Model, Cmd Msg )
init () =
    ( { rates = []
      , assets = []
      , assetsInput = ""
      , today = Nothing
      }
    , fetchRates GotRates
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRates (Just ( today, rates )) ->
            ( { model | today = Just today, rates = rates }, Cmd.none )

        GotRates Nothing ->
            ( { model | rates = [] }, Cmd.none )

        AssetsInputChanged str ->
            ( { model | assetsInput = str }, Cmd.none )

        AssetsInputSubmit ->
            ( { model
                | assets =
                    List.map
                        (\asset -> ( asset, False ))
                        (Result.withDefault [] (decodeAssets model.assetsInput))
              }
            , Cmd.none
            )

        AssetSelected asset ->
            ( { model
                | assets =
                    List.map
                        (\( item, selected ) ->
                            if asset == item then
                                ( item, not selected )

                            else
                                ( item, selected )
                        )
                        model.assets
              }
            , Cmd.none
            )

        AssetsHeaderSelected NameSort ->
            let
                asc =
                    case ( List.head model.assets, List.last model.assets ) of
                        ( Just ( a1, _ ), Just ( a2, _ ) ) ->
                            if a1.name < a2.name then
                                False

                            else
                                True

                        _ ->
                            False

                comp ( a1, _ ) ( a2, _ ) =
                    if asc then
                        compare a1.name a2.name

                    else
                        compare a2.name a1.name
            in
            ( { model | assets = List.sortWith comp model.assets }
            , Cmd.none
            )

        AssetsHeaderSelected AmountSort ->
            let
                sortedAsc =
                    List.sortBy (Tuple.first >> .amount) model.assets

                sortedDesc =
                    List.sortBy (Tuple.first >> .amount >> negate) model.assets
            in
            ( { model
                | assets =
                    if model.assets == sortedAsc then
                        sortedDesc

                    else
                        sortedAsc
              }
            , Cmd.none
            )

        AssetsHeaderSelected YieldSort ->
            let
                sortedAsc =
                    List.sortBy (Tuple.first >> .yield) model.assets

                sortedDesc =
                    List.sortBy (Tuple.first >> .yield >> negate) model.assets
            in
            ( { model
                | assets =
                    if model.assets == sortedAsc then
                        sortedDesc

                    else
                        sortedAsc
              }
            , Cmd.none
            )

        AssetsHeaderSelected MaturitySort ->
            let
                asc =
                    case ( List.head model.assets, List.last model.assets ) of
                        ( Just ( a1, _ ), Just ( a2, _ ) ) ->
                            if Date.compare a1.maturity a2.maturity == Basics.LT then
                                False

                            else
                                True

                        _ ->
                            False

                comp ( a1, _ ) ( a2, _ ) =
                    if asc then
                        Date.compare a1.maturity a2.maturity

                    else
                        Date.compare a2.maturity a1.maturity
            in
            ( { model | assets = List.sortWith comp model.assets }
            , Cmd.none
            )
