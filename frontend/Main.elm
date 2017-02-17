module Main exposing (..)

import Html exposing (program)

import View exposing (..)
import Messages exposing (..)
import Model exposing (..)
import View exposing (..)
import Update exposing (..)

main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = always Sub.none
    }
