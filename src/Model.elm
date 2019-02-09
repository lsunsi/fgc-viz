module Model exposing (Asset, DateRate, Model)

import Date exposing (Date)


type alias DateRate =
    { date : Date
    , rate : Float
    }


type alias Asset =
    { name : String
    , amount : Float
    , yield : Float
    , maturity : Date
    }


type alias Model =
    { rates : List DateRate
    , assets : List Asset
    , assetsInput : String
    , today : Maybe Date
    }
