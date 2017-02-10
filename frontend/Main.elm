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

failureFeedback : Progress -> Html Msg
failureFeedback progress =
  if progress == Failed then
    p [ class "alert alert-danger" ] [ text "Oh my 🙀 I'm sorry, but capturing a new photo failed." ]
  else
    text ""


photoToHtml : Maybe Photo -> Html Msg
photoToHtml possiblyPhoto =
  case possiblyPhoto of
    Just photo ->
      let
        styles = style [ ("border", "1px solid lightgrey")
                       , ("width", "100%")
                       , ("margin-top", "15px")
                       ]
      in
        img [ styles, src photo.src ] []

    Nothing ->
      text ""

captureButton : Progress -> Html Msg
captureButton progress =
  let
    cssClass =
      if progress /= Fetching then "glyphicon glyphicon-camera" else "glyphicon glyphicon-camera spinning"
  in
    button [ style [ ("width", "100%")
                   , ("min-height", "200px")
                   , ("background-color", "#f9f9f9")
                   , ("border", "1px solid lightgrey")
                   , ("font-size", "50px")
                   ]
           , onClick CapturePhoto
           ] [ span [ class cssClass ] [] ]

view : Model -> Html Msg
view model =
  div []
    [ h1 [ class "text-center" ] [ text "Raspberry Pi Camera" ]
    , hr [] []
    , failureFeedback model.state
    , captureButton model.state
    , div [] [ (photoToHtml model.lastPhoto) ]
    ]
