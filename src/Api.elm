module Api exposing (decodeAssets, fetchRates)

import Char
import Date exposing (Date)
import Http
import Json.Decode as D
import Model exposing (Asset, DateRate)
import Parser as P exposing ((|.), (|=), Parser)
import Set


floatParser : Parser Float
floatParser =
    P.andThen
        (String.replace "," "."
            >> String.toFloat
            >> Maybe.map P.succeed
            >> Maybe.withDefault (P.problem ":(")
        )
        (P.variable
            { start = Char.isDigit
            , inner = \c -> Char.isDigit c || c == ','
            , reserved = Set.empty
            }
        )


dateParser : Parser Date
dateParser =
    P.andThen
        (Date.fromIsoString
            >> Result.map P.succeed
            >> Result.withDefault (P.problem ":(")
        )
        (P.variable
            { start = Char.isDigit
            , inner = Char.isDigit
            , reserved = Set.empty
            }
        )


referenceDateParser : Parser Date
referenceDateParser =
    P.succeed (\a -> a)
        |. P.chompUntil "<input type=\"hidden\" name=\"Data1\" ID=\"Data1\""
        |. P.chompUntil "value=\""
        |. P.token "value=\""
        |= dateParser


rateParser : Date -> Parser DateRate
rateParser date =
    P.succeed DateRate
        |. P.chompUntil "<td CLASS=\"tabelaConteudo"
        |. P.chompUntil ">"
        |. P.token ">"
        |= P.map (\int -> Date.add Date.Days int date) P.int
        |. P.chompUntil "<td nowrap CLASS=\"tabelaConteudo"
        |. P.chompUntil ">"
        |. P.token ">"
        |. P.spaces
        |= floatParser


ratesParser : Date -> Parser (List DateRate)
ratesParser date =
    P.sequence
        { start = ""
        , separator = ""
        , end = ""
        , spaces = P.spaces
        , item = rateParser date
        , trailing = P.Mandatory
        }


fetchRates : (Maybe (List DateRate) -> msg) -> Cmd msg
fetchRates msg =
    Http.get
        { url = "https://cors-anywhere.herokuapp.com/http://www2.bmf.com.br/pages/portal/bmfbovespa/boletim1/TxRef1.asp"
        , expect =
            Http.expectString
                (Result.toMaybe
                    >> Maybe.andThen
                        (\str ->
                            P.run referenceDateParser str
                                |> Result.andThen (\date -> P.run (ratesParser date) str)
                                |> Result.toMaybe
                        )
                    >> msg
                )
        }


decimalDecoder : D.Decoder Float
decimalDecoder =
    D.oneOf
        [ D.float
        , D.andThen
            (String.toFloat
                >> Maybe.map D.succeed
                >> Maybe.withDefault (D.fail ":(")
            )
            D.string
        ]


dateDecoder : D.Decoder Date
dateDecoder =
    D.andThen
        (Date.fromIsoString
            >> Result.map D.succeed
            >> Result.withDefault (D.fail ":(")
        )
        D.string


assetsDecoder : D.Decoder (List Asset)
assetsDecoder =
    let
        assetDecoder =
            D.map4 Asset
                (D.field "name" D.string)
                (D.field "amount" decimalDecoder)
                (D.field "yield" decimalDecoder)
                (D.field "maturity_date" dateDecoder)
    in
    D.list (D.field "assets" (D.list (D.maybe assetDecoder)))
        |> D.map (List.concatMap (List.filterMap identity))


decodeAssets : String -> Result D.Error (List Asset)
decodeAssets =
    D.decodeString assetsDecoder
