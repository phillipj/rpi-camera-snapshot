module Model exposing (..)

import Date


type alias Model =
    { selectedPhoto : Maybe Photo
    , photos : List (Maybe Photo)
    , state : Progress
    , historicalState : Progress
    }


type alias Photo =
    { src : String
    , capturedTimestamp : Date.Date
    }


type Progress
    = Initial
    | Fetching
    | Fetched
    | Failed
