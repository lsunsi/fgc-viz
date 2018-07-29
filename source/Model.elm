module Model exposing (..)

import Date exposing (Date)


type alias Interest =
    { date : Date
    , rate : Float
    }


type alias Asset =
    { maturity : Date
    , amount : Float
    , yield : Float
    }


type alias Model =
    { interests : List Interest
    , interestFormDate : String
    , interestFormRate : String
    , assets : List Asset
    }
