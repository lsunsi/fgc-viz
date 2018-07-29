module Main exposing (main)

import Html exposing (program)
import Init exposing (init)
import Model exposing (Model)
import Subscriptions exposing (subscriptions)
import Update exposing (Msg, update)
import View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
