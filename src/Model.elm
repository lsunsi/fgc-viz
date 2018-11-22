module Model exposing (Asset, Model)

import Date exposing (Date)


type alias Asset =
    { name : String
    , maturity : Date
    , amount : Float
    , yield : Float
    }


type alias Model =
    { assetsInput : String
    , assets : List Asset
    }
