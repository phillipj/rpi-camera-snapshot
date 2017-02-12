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
  , photos : List (Maybe Photo)
  , state : Progress
  , historicalState : Progress
  }

init : (Model, Cmd Msg)
init =
  (Model Nothing ([Nothing, Nothing, Nothing]) Initial Initial, requestHistoricalPhotos)


-- UPDATE


type Msg
  = CapturePhoto
  | NewPhoto (Result Http.Error String)
  | FetchHistoricalPhotos
  | HistoricalPhotos (Result Http.Error (List Photo))

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
      ({ model
          | lastPhoto = (jsonToPhoto jsonString)
          , state = Fetched
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


-- VIEW

photosToImgRow : List (Maybe Photo) -> Html Msg
photosToImgRow photos =
  let
    photoToImgRowItem = createPhotoRowItemFn (List.length photos)
    photosAsImg = (List.indexedMap photoToImgRowItem photos)

  in
    p [ style [ ("display", "flex")
              , ("justify-content", "space-around")
              ]
      ] photosAsImg


--                   total photos count -> index -> photo -> html
createPhotoRowItemFn : Int -> Int -> Maybe Photo -> Html Msg
createPhotoRowItemFn =
  -- partial application in action; photosCount is provided when creating the anon function,
  -- the remaining args are provided when invoked per item in List.indexedMap
  \photosCount index possiblyPhoto ->
      let
        isLastPhoto = index == (photosCount - 1)
        rightMargin = if isLastPhoto then "0px" else "5px"

      in
        case possiblyPhoto of
          Just photo ->
            historicalPhotoHtml photo rightMargin
          Nothing ->
            historicalPhotoPlaceholder rightMargin

historicalPhotoHtml : Photo -> String -> Html Msg
historicalPhotoHtml photo rightMargin =
  let
    inlineStyles = [ ("height", "60px")
                   , ("margin-right", rightMargin)
                   ]

  in
    img [ src photo.src, style [("height", "60px")] ] []


historicalPhotoPlaceholder : String -> Html Msg
historicalPhotoPlaceholder rightMargin =
  let
    inlineStyles = [ ("width", "100%")
                   , ("background-color", "#f1f1f1")
                   , ("height", "60px")
                   , ("margin-right", rightMargin)
                   , ("text-align", "center")
                   , ("verical-align", "center")
                   ]

  in
    div [ style inlineStyles ] [ span [ style [("margin-top", "21px"), ("font-size", "15px")]
                                      , class "glyphicon glyphicon-picture"
                                      ] [] ]


historicalFailureFeedback : Progress -> Html Msg
historicalFailureFeedback progress =
  if progress == Failed then
    p [ class "alert alert-danger" ] [ text "Booom 💥 I'm sorry, but fetching historical photos failed." ]
  else
    text ""

captureFailureFeedback : Progress -> Html Msg
captureFailureFeedback progress =
  if progress == Failed then
    p [ class "alert alert-danger" ] [ text "Oh my 🙀 I'm sorry, but capturing a new photo failed." ]
  else
    text ""


photoToImg : Maybe Photo -> Html Msg
photoToImg possiblyPhoto =
  case possiblyPhoto of
    Just photo ->
      let
        styles = style [ ("border", "1px solid lightgrey")
                       , ("width", "100%")
                       ]
      in
        img [ styles, src photo.src ] []

    Nothing ->
      text ""

captureButton : Progress -> Html Msg
captureButton progress =
  let
    cssClass =
      if progress == Fetching then "glyphicon glyphicon-camera spinning" else "glyphicon glyphicon-camera"
  in
    button [ style [ ("width", "100%")
                   , ("height", "150px")
                   , ("background-color", "#f9f9f9")
                   , ("border", "1px solid lightgrey")
                   , ("font-size", "50px")
                   ]
           , onClick CapturePhoto
           ] [ span [ class cssClass ] [] ]

view : Model -> Html Msg
view model =
  div []
    [ div [] [ photosToImgRow model.photos ]
    , historicalFailureFeedback model.historicalState
    , captureFailureFeedback model.state
    , p [] [ (captureButton model.state) ]
    , p [] [ (photoToImg model.lastPhoto) ]
    ]
