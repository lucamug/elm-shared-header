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


headerHeight : String
headerHeight =
    "60px"


css : String
css =
    """
body {
    padding-top: """ ++ headerHeight ++ """ !important;
}
"""


view : Model -> Html Msg
view model =
    let
        isNegative =
            negative model.route
    in
    div
        [ style
            [ ( "font-family", "sans-serif" )
            , ( "background-color"
              , if isNegative then
                    "#000000ee"
                else
                    "#ffffffee"
              )
            , ( "color"
              , if isNegative then
                    "#fff"
                else
                    "#444"
              )
            , ( "border-bottom", "0px solid #eee" )
            , ( "box-shadow", "rgba(0, 0, 0, 0.2) 0px 0px 18px 0px" )
            , ( "padding", "0 20px" )
            , ( "position", "fixed" )
            , ( "top", "0" )
            , ( "right", "0" )
            , ( "left", "0" )
            , ( "z-index", "1000" )
            , ( "height", headerHeight )
            , ( "overflow", "hidden" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "font-size", "13px" )
            , ( "line-height", "10px" )
            ]
        ]
        [ node "style" [] [ text css ]
        , div []
            [ svgHamburger isNegative
            ]
        , div
            [ style
                [ ( "width", "110px" )
                , ( "font-size", "9px" )
                , ( "padding-left", "20px" )
                , ( "white-space", "nowrap" )
                ]
            ]
            [ svgLogo isNegative
            , br [] []
            , text "Experimental Shared Header"
            ]
        , div
            [ style
                [ ( "flex", "0 1 100%" )
                , ( "padding", "0 40px" )
                ]
            ]
            [ case model.route of
                Section1 ->
                    section1

                Top ->
                    viewTop

                NotFound ->
                    viewTop
            ]
        , div []
            [ if isNegative then
                viewLink model "" Top (svgClose isNegative)
              else
                viewLink model sections.section1.name Section1 (svgSearch isNegative)
            ]
        ]


negative : Route -> Bool
negative route =
    case route of
        Section1 ->
            True

        _ ->
            False


pathToName : String -> String
pathToName path =
    if path == "" then
        "Home"
    else
        capitalize path


viewLink : { b | route : a } -> String -> a -> Html Msg -> Html Msg
viewLink model path route content =
    let
        url =
            "/" ++ path

        styled =
            style
                [ ( "display", "inline-block" )
                , ( "width", "24px" )
                ]
    in
    if model.route == route then
        div [ class "selected", styled ] [ text (pathToName path) ]
    else
        a [ href url, onLinkClick url, styled ] [ content ]


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
    text ""


section1 : Html msg
section1 =
    input
        [ placeholder "Search"
        , style
            [ ( "width", "100%" )
            , ( "font-size", "16px" )
            , ( "padding", "3px" )
            , ( "background-color", "white" )
            ]
        ]
        []


defaultParameters : List (Svg.Attribute Msg)
defaultParameters =
    [ Svg.Attributes.preserveAspectRatio "xMinYMid" ]


svgHamburger : Bool -> Html msg
svgHamburger negative =
    Svg.svg [ Svg.Attributes.height "32", Svg.Attributes.width "32" ]
        [ Svg.path
            [ Svg.Attributes.fill
                (if negative then
                    "white"
                 else
                    "black"
                )
            , Svg.Attributes.d
                "M4 10h24a2 2 0 0 0 0-4H4a2 2 0 0 0 0 4zm24 4H4a2 2 0 0 0 0 4h24a2 2 0 0 0 0-4zm0 8H4a2 2 0 0 0 0 4h24a2 2 0 0 0 0-4z"
            ]
            []
        ]


svgSearch : Bool -> Html Msg
svgSearch negative =
    Svg.svg (defaultParameters ++ [ Svg.Attributes.viewBox "0 0 36.22 36.89" ])
        [ Svg.path
            [ Svg.Attributes.fill
                (if negative then
                    "white"
                 else
                    "black"
                )
            , Svg.Attributes.d "M35.83 34.62L26.3 25a15 15 0 1 0-1.95 1.83l9.6 9.64a1.33 1.33 0 0 0 1.9-1.88zM2.67 15A12.38 12.38 0 1 1 15 27.43 12.4 12.4 0 0 1 2.67 15z"
            ]
            []
        ]


svgClose : Bool -> Html Msg
svgClose negative =
    Svg.svg (defaultParameters ++ [ Svg.Attributes.viewBox "0 0 22 22" ])
        [ Svg.path
            [ Svg.Attributes.fill
                (if negative then
                    "white"
                 else
                    "black"
                )
            , Svg.Attributes.d "M15.8 4.64l-4.87 4.88-4.8-4.8-1.5 1.47L9.46 11l-4.8 4.8 1.47 1.5 4.8-4.82 4.9 4.88 1.47-1.48L12.4 11l4.9-4.88-1.5-1.48z"
            ]
            []
        ]


svgLogo : Bool -> Html Msg
svgLogo negative =
    Svg.svg (defaultParameters ++ [ Svg.Attributes.width "110", Svg.Attributes.viewBox "0 0 201.76 34.34" ])
        [ Svg.circle
            [ Svg.Attributes.fill
                (if negative then
                    "white"
                 else
                    "#bf0000"
                )
            , Svg.Attributes.cx "17"
            , Svg.Attributes.cy "17.3"
            , Svg.Attributes.r "17"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fill
                (if negative then
                    "black"
                 else
                    "white"
                )
            , Svg.Attributes.d "M14.8 26.5v-5.7h2.4l4.3 5.7h4.3l-5.1-6.9A6.3 6.3 0 0 0 17 8.2h-5.7v18.3zm0-14.8H17a2.8 2.8 0 1 1 0 5.6h-2.2z"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fill
                (if negative then
                    "white"
                 else
                    "black"
                )
            , Svg.Attributes.d "M43.2 32.6v-9.5h4.1l7.2 9.5h7.2l-8.6-11.4A10.6 10.6 0 0 0 47 2h-9.6v30.6zm0-24.8H47a4.7 4.7 0 1 1 0 9.5h-3.8zm105.7 18a2.6 2.6 0 0 1-5.1-1.3V14h8.5V8.1h-8.5V2H138v6.1h-4.1V14h4.1v10.6a8.5 8.5 0 0 0 16.5 2.8zM77 8.1v1.1a10.5 10.5 0 0 0-5.7-1.7C65 7.5 60 13.3 60 20.4s5 12.8 11.3 12.8a10.5 10.5 0 0 0 5.7-1.7v1.1h5.8V8.1zm-5.7 19.3c-3 0-5.6-3.1-5.6-7s2.5-7 5.6-7 5.7 3.2 5.7 7-2.5 7-5.7 7zM126 8.1v14.4a4.9 4.9 0 0 1-9.8 0V8.1h-5.8v14.4A10.7 10.7 0 0 0 126 32v.6h5.8V8.1zm65-.6a10.7 10.7 0 0 0-4.9 1.2v-.6h-5.8v24.5h5.8V18.2a4.9 4.9 0 1 1 9.8 0v14.4h5.8V18.2A10.7 10.7 0 0 0 191 7.5zm-13 12.9c0-7.1-5.2-12.9-11.5-12.9S155 13.2 155 20.4a13 13 0 0 0 12.3 12.9 12 12 0 0 0 10.1-5.5l-5-3c-4.4 5.3-10.3 1.7-11-2.7H178a15.2 15.2 0 0 0 .1-1.7zm-6.6-3.5h-9.8c1.1-4.8 8.7-5.8 9.8 0zm-73.7 2.7l11.5-11.5H101L92 17V0h-5.8v32.6H92V22.2l10.4 10.4h8.2l-13-13z"
            ]
            []
        ]


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
