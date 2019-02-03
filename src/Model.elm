module Model exposing (DateRate, Model)

import Date exposing (Date)


type alias DateRate =
    { date : Date
    , rate : Float
    }


type alias Model =
    { rates : List DateRate
    }
