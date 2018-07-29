module Subscriptions exposing (subscriptions)

import Storage exposing (retrieveModel)
import Update exposing (Msg(ModelRetrieved))


subscriptions : model -> Sub Msg
subscriptions _ =
    retrieveModel ModelRetrieved
