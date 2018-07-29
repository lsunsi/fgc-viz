module Init exposing (init)

import Model exposing (Model)


init : ( Model, Cmd msg )
init =
    { interests = []
    }
        ! []
