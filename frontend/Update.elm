module Update exposing (..)

import Http
import Json.Decode as Decode

import Model exposing (..)
import Messages exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CapturePhoto ->
      ({ model | state = Fetching }, requestNewPhoto)
    NewPhoto (Ok jsonString) ->
      let
        photo = (jsonToPhoto jsonString)
      in
        ({ model
            | selectedPhoto = photo
            , state = Fetched
            , photos = photo :: model.photos
         }, Cmd.none)
    NewPhoto (Err _) ->
      ({ model | state = Failed }, Cmd.none)
    FetchHistoricalPhotos ->
      ({ model | historicalState = Fetching }, requestHistoricalPhotos)
    HistoricalPhotos (Ok photos) ->
      ({ model
          | photos = (toMaybePhotos photos)
          , historicalState = Fetched
       }, Cmd.none)
    HistoricalPhotos (Err err) ->
      ({ model | historicalState = Failed }, Cmd.none)


init : (Model, Cmd Msg)
init =
  (Model Nothing ([Nothing, Nothing, Nothing]) Initial Initial, requestHistoricalPhotos)


jsonPhotoDecoder : Decode.Decoder Photo
jsonPhotoDecoder =
  Decode.map Photo
    (Decode.field "src" Decode.string)

jsonPhotoListDecoder : Decode.Decoder (List Photo)
jsonPhotoListDecoder =
  Decode.list jsonPhotoDecoder

jsonToPhoto : String -> Maybe Photo
jsonToPhoto str =
  let
    decoded = Decode.decodeString jsonPhotoDecoder str
  in
    case decoded of
      Ok photo ->
        Just photo

      Err msg ->
        Nothing

requestNewPhoto : Cmd Msg
requestNewPhoto =
  let
    request = Http.getString "photo"
  in
    Http.send NewPhoto request

requestHistoricalPhotos : Cmd Msg
requestHistoricalPhotos =
  let
    request = Http.get "historical-photos" jsonPhotoListDecoder
  in
    Http.send HistoricalPhotos request

toMaybePhotos : List Photo -> List (Maybe Photo)
toMaybePhotos photos =
  List.map (\photo -> Just photo) photos
