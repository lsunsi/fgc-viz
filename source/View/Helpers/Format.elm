module View.Helpers.Format exposing (date, number, percentage)

import Date exposing (Date)
import Date.Extra as Date
import FormatNumber
import FormatNumber.Locales exposing (usLocale)


percentage : Float -> String
percentage f =
    number (f * 100) ++ "%"


number : Float -> String
number f =
    FormatNumber.format usLocale f


date : Date -> String
date =
    Date.toFormattedString "yyyy-MM-dd"
