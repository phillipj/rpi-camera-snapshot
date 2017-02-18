module Model exposing (..)


type alias Model =
    { selectedPhoto : Maybe Photo
    , photos : List (Maybe Photo)
    , state : Progress
    , historicalState : Progress
    }


type alias Photo =
    { src : String
    }


type Progress
    = Initial
    | Fetching
    | Fetched
    | Failed
