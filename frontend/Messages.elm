module Messages exposing (Msg(..))

import Http

import Model exposing (..)


type Msg
  = CapturePhoto
  | NewPhoto (Result Http.Error Photo)
  | FetchHistoricalPhotos
  | HistoricalPhotos (Result Http.Error (List Photo))
  | DisplayPhoto Photo
