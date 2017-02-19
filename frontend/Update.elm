module Update exposing (..)

import Http
import Json.Decode as Decode
import Date
import Model exposing (..)
import Messages exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CapturePhoto ->
            ( { model | state = Fetching }, requestNewPhoto )

        NewPhoto (Ok photo) ->
            ( { model
                | selectedPhoto = Just photo
                , state = Fetched
                , photos = Just photo :: model.photos
              }
            , Cmd.none
            )

        NewPhoto (Err _) ->
            ( { model | state = Failed }, Cmd.none )

        FetchHistoricalPhotos ->
            ( { model | historicalState = Fetching }, requestHistoricalPhotos )

        HistoricalPhotos (Ok photos) ->
            ( { model
                | photos = (toMaybePhotos photos)
                , historicalState = Fetched
              }
            , Cmd.none
            )

        HistoricalPhotos (Err err) ->
            ( { model | historicalState = Failed }, Cmd.none )

        DisplayPhoto photo ->
            ( { model | selectedPhoto = Just photo }, Cmd.none )


init : ( Model, Cmd Msg )
init =
    ( Model Nothing ([ Nothing, Nothing, Nothing ]) Initial Initial, requestHistoricalPhotos )


jsonPhotoDecoder : Decode.Decoder Photo
jsonPhotoDecoder =
    Decode.map2 Photo
        (Decode.field "src" Decode.string)
        (Decode.field "capturedTimestamp" Decode.string
            {- since there is no Decode.date, we have to parse date from string manually
               after it has been read into a string
            -}
            |>
                Decode.andThen
                    (\str ->
                        case Date.fromString str of
                            Err err ->
                                Decode.fail err

                            Ok parsedDate ->
                                Decode.succeed parsedDate
                    )
        )


jsonPhotoListDecoder : Decode.Decoder (List Photo)
jsonPhotoListDecoder =
    Decode.list jsonPhotoDecoder


requestNewPhoto : Cmd Msg
requestNewPhoto =
    let
        request =
            Http.get "photo" jsonPhotoDecoder
    in
        Http.send NewPhoto request


requestHistoricalPhotos : Cmd Msg
requestHistoricalPhotos =
    let
        request =
            Http.get "historical-photos" jsonPhotoListDecoder
    in
        Http.send HistoricalPhotos request


toMaybePhotos : List Photo -> List (Maybe Photo)
toMaybePhotos photos =
    List.map (\photo -> Just photo) photos
