module View.Helpers.Format exposing (date, percentage)

import Date exposing (Date)
import Date.Extra as Date
import FormatNumber
import FormatNumber.Locales exposing (usLocale)


percentage : Float -> String
percentage f =
    FormatNumber.format usLocale (f * 100) ++ "%"


date : Date -> String
date =
    Date.toFormattedString "yyyy-MM-dd"
