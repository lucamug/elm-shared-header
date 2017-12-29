port module Main exposing (main)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Navigation
import Svg
import Svg.Attributes
import UrlParser


port urlChange : String -> Cmd msg


type Msg
    = ChangeLocation String
    | UrlChange Navigation.Location


type alias Model =
    { route : Route
    , history : List String
    , titleHistory : List String
    , location : Navigation.Location
    , version : String
    , title : String
    }


type Route
    = Top
    | Section1
    | NotFound


capitalize : String -> String
capitalize str =
    case String.uncons str of
        Nothing ->
            str

        Just ( firstLetter, rest ) ->
            let
                newFirstLetter =
                    Char.toUpper firstLetter
            in
            String.cons newFirstLetter rest


sections :
    { section1 : { name : String }
    }
sections =
    { section1 =
        { name = "Search"
        }
    }


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map Top UrlParser.top
        , UrlParser.map Section1 (UrlParser.s sections.section1.name)
        ]


routeToPath : Route -> String
routeToPath route =
    case route of
        Top ->
            ""

        Section1 ->
            sections.section1.name

        NotFound ->
            "notFound"


locationToRoute : Navigation.Location -> Route
locationToRoute location =
    case UrlParser.parsePath matchers location of
        Just route ->
            route

        Nothing ->
            NotFound


updateTitleAndMetaDescription : Model -> Cmd msg
updateTitleAndMetaDescription model =
    urlChange (pageTitle model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeLocation pathWithSlash ->
            ( model, Navigation.newUrl pathWithSlash )

        UrlChange location ->
            let
                newRoute =
                    locationToRoute location

                newHistory =
                    location.pathname :: model.history

                newModel =
                    { model | route = newRoute, history = newHistory, location = location }
            in
            ( newModel
            , updateTitleAndMetaDescription newModel
            )


onLinkClick : String -> Attribute Msg
onLinkClick path =
    onWithOptions "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Json.Decode.succeed (ChangeLocation path))


css : String
css =
    """
#app5674 {
    color: #555;
    font-family: sans-serif;
    background-color: #ffa50033;
    border: 2px solid orange;
    margin: 10px;
    padding: 10px;
    color: orange;
}
"""


view : Model -> Html Msg
view model =
    div [ id "app5674" ]
        [ node "style" [] [ text css ]
        , div
            [ style
                [ ( "width", "250px" )
                , ( "text-align", "center" )
                ]
            ]
            [ rakuten
            , text "Experimental Shared Header"
            ]
        , viewNavigation model

        -- , viewMetadata model
        , viewPage model
        ]


pathToName : String -> String
pathToName path =
    if path == "" then
        "Home"
    else
        capitalize path


viewLink : Model -> String -> Route -> Html Msg
viewLink model path route =
    let
        url =
            "/" ++ path
    in
    li
        []
        [ if model.route == route then
            div [ class "selected" ] [ text (pathToName path) ]
          else
            a [ href url, onLinkClick url ] [ text (pathToName path) ]
        ]


viewNavigation : Model -> Html Msg
viewNavigation model =
    ul [ class "navigation" ]
        [ viewLink model "" Top
        , viewLink model sections.section1.name Section1
        ]


viewPage : Model -> Html Msg
viewPage model =
    div []
        [ h2 []
            [ model.route
                |> routeToPath
                |> pathToName
                |> text
            ]
        , div []
            [ case model.route of
                Section1 ->
                    section1

                Top ->
                    viewTop

                NotFound ->
                    text "Page not Found"
            ]
        ]


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        model =
            initModel location
    in
    ( model
    , initCmd model location
    )


initModel : Navigation.Location -> Model
initModel location =
    { route = locationToRoute location
    , history = [ location.pathname ]
    , titleHistory = []
    , location = location
    , version = "1"
    , title = "Shared Header"
    }


pageTitle : Model -> String
pageTitle model =
    model.title


initCmd : Model -> Navigation.Location -> Cmd Msg
initCmd model location =
    Cmd.batch
        []


viewTop : Html Msg
viewTop =
    div []
        [ text "top"
        ]


section1 : Html msg
section1 =
    div [] [ text "section1" ]


defaultParameters : List (Svg.Attribute Msg)
defaultParameters =
    [ Svg.Attributes.preserveAspectRatio "xMinYMid" ]


rakuten : Html Msg
rakuten =
    Svg.svg (defaultParameters ++ [ Svg.Attributes.viewBox "0 0 201.76 34.34" ])
        [ Svg.circle [ Svg.Attributes.fill "#bf0000", Svg.Attributes.cx "17.01", Svg.Attributes.cy "17.33", Svg.Attributes.r "17.01" ] []
        , Svg.path [ Svg.Attributes.fill "white", Svg.Attributes.d "M14.76 26.47V20.8h2.46l4.25 5.67h4.35l-5.14-6.84A6.3 6.3 0 0 0 17 8.2h-5.7v18.27zm0-14.8H17a2.83 2.83 0 1 1 0 5.66h-2.24z" ] []
        , Svg.path [ Svg.Attributes.d "M148.85 25.82a2.64 2.64 0 0 1-5.06-1.3V13.95h8.56V8.13h-8.56V2H138v6.13h-4.13v5.82H138v10.57a8.47 8.47 0 0 0 16.54 2.82zM77 8.13v1.1a10.5 10.5 0 0 0-5.67-1.7C65 7.53 59.86 13.3 59.86 20.4S65 33.23 71.33 33.23a10.48 10.48 0 0 0 5.67-1.7v1.1h5.82V8.14zm-5.67 19.3c-3.12 0-5.66-3.17-5.66-7s2.54-7 5.66-7 5.67 3.15 5.67 7-2.54 7-5.67 7zM126 8.13v14.4a4.9 4.9 0 0 1-9.8 0V8.13h-5.8v14.4A10.7 10.7 0 0 0 126 32v.6h5.82V8.12zM191 7.53a10.65 10.65 0 0 0-4.9 1.2v-.6h-5.82v24.5h5.82v-14.4a4.9 4.9 0 1 1 9.8 0v14.4h5.8v-14.4A10.73 10.73 0 0 0 191 7.54zM178 20.38c0-7.1-5.15-12.88-11.48-12.88S155 13.17 155 20.38c0 7.6 6.47 12.88 12.3 12.88a12 12 0 0 0 10.1-5.5l-5.07-2.92c-4.3 5.25-10.28 1.7-10.88-2.75h16.4a15.22 15.22 0 0 0 .15-1.72zm-6.58-3.5h-9.8c1.1-4.75 8.73-5.74 9.8.02zM97.73 19.62l11.5-11.5h-8.24L92.1 17V0h-5.8v32.64h5.8v-10.4l10.4 10.4h8.23L97.73 19.62z" ] []
        , Svg.path [ Svg.Attributes.d "M43.23 32.64v-9.5h4.1l7.13 9.5h7.28l-8.6-11.46A10.55 10.55 0 0 0 47 2h-9.58v30.64zm0-24.8H47a4.74 4.74 0 1 1 0 9.5h-3.8z" ] []
        ]


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
