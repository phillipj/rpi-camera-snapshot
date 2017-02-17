module Messages exposing (Msg(..))

import Http

import Model exposing (..)


type Msg
  = CapturePhoto
  | NewPhoto (Result Http.Error String)
  | FetchHistoricalPhotos
  | HistoricalPhotos (Result Http.Error (List Photo))
