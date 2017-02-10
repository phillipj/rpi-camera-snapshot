module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode

main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = always Sub.none
    }


-- MODEL


type alias Photo =
  { src : String
  }

type Progress =
  Initial | Fetching | Fetched | Failed

type alias Model =
  { lastPhoto : Maybe Photo
  , state : Progress
  }

init : (Model, Cmd Msg)
init =
  (Model Nothing Initial, Cmd.none)


-- UPDATE


type Msg
  = CapturePhoto
  | NewPhoto (Result Http.Error String)

jsonPhotoDecoder : Decode.Decoder Photo
jsonPhotoDecoder =
  Decode.map Photo
    (Decode.field "src" Decode.string)

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

resolveReqIdFilter : Maybe String -> String -> Maybe String
resolveReqIdFilter currentFilter wantedFilter =
  case currentFilter of
    (Just req_id) ->
      Nothing
    Nothing ->
      Just wantedFilter

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CapturePhoto ->
      ({ model | state = Fetching }, requestNewPhoto)
    NewPhoto (Ok jsonString) ->
      (Model (jsonToPhoto jsonString) Fetched, Cmd.none)
    NewPhoto (Err _) ->
      ({ model | state = Failed }, Cmd.none)


-- VIEW

progressToHtml : Progress -> Html Msg
progressToHtml state =
  case state of
    Initial ->
      p [] [ text "" ]
    Fetching ->
      p [] [ text "Capturing photo.." ]
    Fetched ->
      p [] [ text "Photo captured successfully." ]
    Failed ->
      p [ style [("color", "red")] ] [ text "Failed to capture photo 💥" ]


photoToHtml : Maybe Photo -> Html Msg
photoToHtml possiblyPhoto =
  case possiblyPhoto of
    Just photo ->
      let
        styles = style [ ("border", "2px solid lightgrey")
                       , ("width", "100%")
                       ]
      in
        img [ styles, src photo.src ] []

    Nothing ->
      text ""


view : Model -> Html Msg
view model =
  div []
    [ h1 [ class "text-center" ] [ text "Raspberry Pi Camera" ]
    , hr [] []
    , button [ onClick CapturePhoto ] [ text ("Capture photo") ]
    , progressToHtml model.state
    , div [] [ (photoToHtml model.lastPhoto) ]
    ]
