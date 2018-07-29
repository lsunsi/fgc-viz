module Update exposing (update)

import Model exposing (Model)


update : msg -> Model -> ( Model, Cmd msg )
update _ model =
    model ! []
