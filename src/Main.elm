module Main exposing (main)

import Browser exposing (element)
import Model exposing (Model)
import State exposing (Msg, init, update)
import View exposing (view)


main : Program () Model Msg
main =
    element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
