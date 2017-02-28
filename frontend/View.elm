module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, src, style, href)
import Html.Events exposing (onClick)
import Date
import Date.Format
import Model exposing (..)
import Messages exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ div [] [ (photosToImgRow model.photos model.selectedPhoto) ]
        , historicalFailureFeedback model.historicalState
        , captureFailureFeedback model.state
        , p [] [ (captureButton model.state) ]
        , p [ style [ ( "position", "relative" ) ] ]
            [ (photoToImg model.selectedPhoto)
            , (photoDateOverlay model.selectedPhoto)
            ]
        ]


photosToImgRow : List (Maybe Photo) -> Maybe Photo -> Html Msg
photosToImgRow allPhotos selectedPhoto =
    let
        photosToDisplay =
            List.take 3 allPhotos

        photoToImg =
            photoToImgRowItem (List.length photosToDisplay) selectedPhoto
    in
        p
            [ style
                [ ( "display", "flex" )
                , ( "justify-content", "space-around" )
                , ( "height", "70px" )
                ]
            ]
            (List.indexedMap photoToImg photosToDisplay)



-- partial application in action; photosCount is provided when creating the anon function,
-- the remaining args are provided when invoked per item in List.indexedMap
--                   total photos count -> index -> photo -> html


photoToImgRowItem : Int -> Maybe Photo -> Int -> Maybe Photo -> Html Msg
photoToImgRowItem photosCount selectedPhoto index possiblyPhoto =
    let
        isLastPhoto =
            index == (photosCount - 1)

        isSelected =
            possiblyPhoto == selectedPhoto

        rightMargin =
            if isLastPhoto then
                "0px"
            else
                "5px"
    in
        case possiblyPhoto of
            Just photo ->
                historicalPhotoHtml photo rightMargin isSelected

            Nothing ->
                historicalPhotoPlaceholder rightMargin


historicalPhotoHtml : Photo -> String -> Bool -> Html Msg
historicalPhotoHtml photo rightMargin isSelected =
    let
        baseStyles =
            [ ( "height", "60px" ), ( "transition", "0.15s linear" ) ]

        extraStyles =
            if isSelected then
                [ ( "outline", "2px solid grey" ), ( "height", "65px" ) ]
            else
                [ ( "outline", "1px solid lightgrey" ) ]
    in
        a [ href "#", onClick (DisplayPhoto photo) ]
            [ img [ src photo.src, style (baseStyles ++ extraStyles) ] []
            ]


historicalPhotoPlaceholder : String -> Html Msg
historicalPhotoPlaceholder rightMargin =
    let
        inlineStyles =
            [ ( "width", "100%" )
            , ( "background-color", "#f1f1f1" )
            , ( "height", "60px" )
            , ( "margin-right", rightMargin )
            , ( "text-align", "center" )
            , ( "verical-align", "center" )
            ]
    in
        div [ style inlineStyles ]
            [ span
                [ style [ ( "margin-top", "21px" ), ( "font-size", "15px" ) ]
                , class "glyphicon glyphicon-picture"
                ]
                []
            ]


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
                styles =
                    style
                        [ ( "position", "absolute" )
                        , ( "border", "1px solid lightgrey" )
                        , ( "width", "100%" )
                        ]
            in
                img [ styles, src photo.src ] []

        Nothing ->
            text ""


photoDateOverlay : Maybe Photo -> Html Msg
photoDateOverlay possiblyPhoto =
    case possiblyPhoto of
        Just photo ->
            let
                styles =
                    style
                        [ ( "position", "absolute" )
                        , ( "width", "100%" )
                        , ( "padding", "5px" )
                        , ( "z-index", "2" )
                        , ( "background-color", "black" )
                        , ( "color", "white" )
                        , ( "opacity", "0.5" )
                        , ( "font-size", "17px" )
                        , ( "font-weight", "bold" )
                        , ( "text-align", "center" )
                        ]
            in
                span [ styles ] [ text (formatOverlayDate photo.capturedTimestamp) ]

        Nothing ->
            text ""


formatOverlayDate : Date.Date -> String
formatOverlayDate =
    Date.Format.format "%d/%m-%y %H:%M"


captureButton : Progress -> Html Msg
captureButton progress =
    let
        cssClass =
            if progress == Fetching then
                "glyphicon glyphicon-camera spinning"
            else
                "glyphicon glyphicon-camera"
    in
        button
            [ style
                [ ( "width", "100%" )
                , ( "height", "150px" )
                , ( "background-color", "#f9f9f9" )
                , ( "border", "1px solid lightgrey" )
                , ( "outline", "0" )
                , ( "font-size", "50px" )
                ]
            , onClick CapturePhoto
            ]
            [ span [ class cssClass ] [] ]
