module UpdateTest exposing (assetsInputChanged)

import Expect exposing (Expectation)
import Fuzz exposing (string)
import Model exposing (Model)
import Test exposing (Test, fuzz)
import Update exposing (Msg(..), update)


assetsInputChanged : Test
assetsInputChanged =
    fuzz string "it sets model property accordingly" <|
        \str ->
            Expect.all
                [ \( model, _ ) -> Expect.equal model (Model str)
                , \( _, cmd ) -> Expect.equal cmd Cmd.none
                ]
                (update (AssetsInputChanged str) (Model ""))
