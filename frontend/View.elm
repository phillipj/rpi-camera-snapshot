module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)

import Model exposing (..)
import Messages exposing (..)

view : Model -> Html Msg
view model =
  div []
    [ div [] [ photosToImgRow model.photos ]
    , historicalFailureFeedback model.historicalState
    , captureFailureFeedback model.state
    , p [] [ (captureButton model.state) ]
    , p [] [ (photoToImg model.selectedPhoto) ]
    ]


photosToImgRow : List (Maybe Photo) -> Html Msg
photosToImgRow photos =
  let
    photoToImg = photoToImgRowItem (List.length photos)

  in
    p [ style [ ("display", "flex")
              , ("justify-content", "space-around")
              ]
      ] (List.indexedMap photoToImg photos)


-- partial application in action; photosCount is provided when creating the anon function,
-- the remaining args are provided when invoked per item in List.indexedMap
--                   total photos count -> index -> photo -> html
photoToImgRowItem : Int -> Int -> Maybe Photo -> Html Msg
photoToImgRowItem photosCount index possiblyPhoto =
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
