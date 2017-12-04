module Tests exposing (all)

import AES exposing (..)
import AES.Types exposing (..)
import AES.Utility exposing (..)
import Array exposing (Array, fromList, repeat)
import BitwiseInfix exposing (..)
import Expect exposing (Expectation)
import List
import Maybe exposing (withDefault)
import Test exposing (..)


log =
    Debug.log


{-| change to True to log JSON input & output results
-}
enableLogging : Bool
enableLogging =
    False


maybeLog : String -> a -> a
maybeLog label value =
    if enableLogging then
        log label value
    else
        value


all : Test
all =
    Test.concat <|
        List.concat
            [ List.map doTest intData
            , List.map doTest arrayData
            ]


expectResult : Result err a -> Result err a -> Expectation
expectResult sb was =
    case maybeLog "  result" was of
        Err err ->
            case sb of
                Err _ ->
                    Expect.true "You shouldn't ever see this." True

                Ok _ ->
                    Expect.false (toString err) True

        Ok wasv ->
            case sb of
                Err _ ->
                    Expect.false "Expected an error but didn't get one." True

                Ok sbv ->
                    Expect.equal sbv wasv


doTest : ( String, a, a ) -> Test
doTest ( name, was, sb ) =
    test name
        (\_ ->
            expectResult (Ok sb) (Ok was)
        )


lo1 =
    0x81


hi1 =
    0x83


lo2 =
    0xC1


hi2 =
    0xC3


lo3 =
    0xC5


hi3 =
    0xC7


lo4 =
    0xCD


hi4 =
    0xCF


word1 =
    makeword hi1 lo1


intData : List ( String, Int, Int )
intData =
    [ ( "1+1", 1 + 1, 2 )
    , ( "lobyte", lobyte word1, lo1 )
    , ( "hibyte", hibyte word1, hi1 )
    , ( "swapbytes", swapbytes word1, makeword lo1 hi1 )
    , ( "rotWord32L"
      , rotWord32L <| makeWord32 hi1 lo1 hi2 lo2
      , makeWord32 lo1 hi2 lo2 hi1
      )
    , ( "makeWordFromByteArray"
      , makeWordFromByteArray 1 <| fromList [ 0, hi1, lo1, 0 ]
      , word1
      )
    , ( "makeWord32", makeWord32 hi1 lo1 hi2 lo2, -2088647743 )
    , ( "subWord32", subWord32 (makeWord32 hi1 lo1 hi2 lo2), -334745992 )
    , ( "makeWord32FromByteArray"
      , makeWord32FromByteArray 2 <| fromList [ 0, 0, hi1, lo1, hi2, lo2, 0, 0 ]
      , makeWord32 hi1 lo1 hi2 lo2
      )
    ]


word2 =
    makeword hi2 lo2


word3 =
    makeword hi3 lo3


word4 =
    makeword hi4 lo4


arrayData : List ( String, Array Int, Array Int )
arrayData =
    [ ( "rotatePairsRight"
      , arrayRotatePairsRight <|
            fromList [ word1, word2, word3, word4 ]
      , fromList
            [ makeword lo2 hi1
            , makeword lo1 hi2
            , makeword lo4 hi3
            , makeword lo3 hi4
            ]
      )
    , ( "ft3", ft3_, ft3_from_lisp )
    , ( "kt3", kt3_, kt3_from_lisp )
    , ( "makeBytesFromWord"
      , makeBytesFromWord word1 1 (repeat 4 0)
      , fromList [ 0, hi1, lo1, 0 ]
      )
    , ( "fillByteArrayFromWords"
      , fillByteArrayFromWords [ word1, word2, word3, word4 ]
      , fromList [ hi1, lo1, hi2, lo2, hi3, lo3, hi4, lo4 ]
      )
    , ( "word32ArrayToWordArray"
      , word32ArrayToWordArray <|
            fromList
                [ makeWord32 hi1 lo1 hi2 lo2
                , makeWord32 hi3 lo3 hi4 lo4
                ]
      , fromList
            [ makeword hi1 lo1
            , makeword hi2 lo2
            , makeword hi3 lo3
            , makeword hi4 lo4
            ]
      )
    ]



---
--- Big arrays below here. Move along. Nothing too see.
---


{-| Computed by (ft3-to-elm) in aes16.lisp
-}
ft3_from_lisp : Array Int
ft3_from_lisp =
    fromList <|
        List.concat
            [ [ 25443, 42438, 31868, 34040, 30583, 39406, 31611, 36342, 62194 ]
            , [ 3583, 27499, 48598, 28527, 45534, 50629, 21649, 12336, 20576 ]
            , [ 257, 770, 26471, 43470, 11051, 32086, 65278, 6631, 55255, 25269 ]
            , [ 43947, 58957, 30326, 39660, 51914, 17807, 33410, 40223, 51657 ]
            , [ 16521, 32125, 34810, 64250, 5615, 22873, 60338, 18247, 51598 ]
            , [ 61680, 3067, 44461, 60481, 54484, 26547, 41634, 64863, 44975 ]
            , [ 59973, 40092, 48931, 42148, 63315, 29298, 38628, 49344, 23451 ]
            , [ 47031, 49781, 65021, 7393, 37779, 44605, 9766, 27212, 13878 ]
            , [ 23148, 16191, 16766, 63479, 757, 52428, 20355, 13364, 23656 ]
            , [ 42405, 62545, 58853, 13521, 61937, 2297, 29041, 37858, 55512 ]
            , [ 29611, 12593, 21346, 5397, 16170, 1028, 3080, 51143, 21141 ]
            , [ 8995, 25926, 50115, 24221, 6168, 10288, 38550, 41271, 1285 ]
            , [ 3850, 39578, 46383, 1799, 2318, 4626, 13860, 32896, 39707 ]
            , [ 58082, 15839, 60395, 9933, 10023, 26958, 45746, 52607, 30069 ]
            , [ 40938, 2313, 6930, 33667, 40477, 11308, 29784, 6682, 11828 ]
            , [ 6939, 11574, 28270, 45788, 23130, 61108, 41120, 64347, 21074 ]
            , [ 63140, 15163, 19830, 54998, 25015, 46003, 52861, 10537, 31570 ]
            , [ 58339, 16093, 12079, 29022, 33924, 38675, 21331, 62886, 53713 ]
            , [ 26809, 0, 0, 60909, 11457, 8224, 24640, 64764, 8163, 45489 ]
            , [ 51321, 23387, 60854, 27242, 48852, 52171, 18061, 48830, 55655 ]
            , [ 14649, 19314, 19018, 56980, 19532, 54424, 22616, 59568, 53199 ]
            , [ 19077, 53456, 27579, 61423, 10949, 43690, 58703, 64507, 5869 ]
            , [ 17219, 50566, 19789, 55194, 13107, 21862, 34181, 37905, 17733 ]
            , [ 53130, 63993, 4329, 514, 1540, 32639, 33278, 20560, 61600 ]
            , [ 15420, 17528, 40863, 47653, 43176, 58187, 20817, 62370, 41891 ]
            , [ 65117, 16448, 49280, 36751, 35333, 37522, 44351, 40349, 48161 ]
            , [ 14392, 18544, 62965, 1265, 48316, 57187, 46774, 49527, 56026 ]
            , [ 30127, 8481, 25410, 4112, 12320, 65535, 6885, 62451, 3837 ]
            , [ 53970, 28095, 52685, 19585, 3084, 5144, 4883, 13606, 60652 ]
            , [ 12227, 24415, 57790, 38807, 41525, 17476, 52360, 5911, 14638 ]
            , [ 50372, 22419, 42919, 62037, 32382, 33532, 15677, 18298, 25700 ]
            , [ 44232, 23901, 59322, 6425, 11058, 29555, 38374, 24672, 41152 ]
            , [ 33153, 38937, 20303, 53662, 56540, 32675, 8738, 26180, 10794 ]
            , [ 32340, 37008, 43835, 34952, 33547, 17990, 51852, 61166, 10695 ]
            , [ 47288, 54123, 5140, 15400, 57054, 31143, 24158, 58044, 2827 ]
            , [ 7446, 56283, 30381, 57568, 15323, 12850, 22116, 14906, 20084 ]
            , [ 2570, 7700, 18761, 56210, 1542, 2572, 9252, 27720, 23644, 58552 ]
            , [ 49858, 23967, 54227, 28349, 44204, 61251, 25186, 42692, 37265 ]
            , [ 43065, 38293, 42033, 58596, 14291, 31097, 35826, 59367, 13013 ]
            , [ 51400, 17291, 14135, 22894, 28013, 47066, 36237, 35841, 54741 ]
            , [ 25777, 20046, 53916, 43433, 57417, 27756, 46296, 22102, 64172 ]
            , [ 62708, 2035, 60138, 9679, 25957, 45002, 31354, 36596, 44718 ]
            , [ 59719, 2056, 6160, 47802, 54639, 30840, 35056, 9509, 28490 ]
            , [ 11822, 29276, 7196, 9272, 42662, 61783, 46260, 51059, 50886 ]
            , [ 20887, 59624, 9163, 56797, 31905, 29812, 40168, 7967, 8510 ]
            , [ 19275, 56726, 48573, 56417, 35723, 34317, 35466, 34063, 28784 ]
            , [ 37088, 15934, 17020, 46517, 50289, 26214, 43724, 18504, 55440 ]
            , [ 771, 1286, 63222, 503, 3598, 4636, 24929, 41922, 13621, 24426 ]
            , [ 22359, 63918, 47545, 53353, 34438, 37143, 49601, 22681, 7453 ]
            , [ 10042, 40606, 47399, 57825, 14553, 63736, 5099, 39064, 45867 ]
            , [ 4369, 13090, 26985, 48082, 55769, 28841, 36494, 35079, 38036 ]
            , [ 42803, 39835, 46637, 7710, 8764, 34695, 37397, 59881, 8393 ]
            , [ 52942, 18823, 21845, 65450, 10280, 30800, 57311, 31397, 35980 ]
            , [ 36611, 41377, 63577, 35209, 32777, 3341, 5914, 49087, 55909 ]
            , [ 59110, 12759, 16962, 50820, 26728, 47312, 16705, 50050, 39321 ]
            , [ 45097, 11565, 30554, 3855, 4382, 45232, 52091, 21588, 64680 ]
            , [ 48059, 54893, 5654, 14892 ]
            ]


{-| Computed by (kt3-to-elm) in aes16.lisp
-}
kt3_from_lisp : Array Int
kt3_from_lisp =
    fromList <|
        List.concat
            [ [ 0, 151849742, 303699484, 454499602, 607398968, 758720310, 908999204 ]
            , [ 1059270954, 1214797936, 1097159550, 1517440620, 1400849762, 1817998408 ]
            , [ 1699839814, 2118541908, 2001430874, -1865371424, -1713521682 ]
            , [ -2100648196, -1949848078, -1260086056, -1108764714, -1493267772 ]
            , [ -1342996022, -658970480, -776608866, -895287668, -1011878526, -57883480 ]
            , [ -176042074, -292105548, -409216582, 1002142683, 850817237, 698445255 ]
            , [ 548169417, 529487843, 377642221, 227885567, 77089521, 1943217067 ]
            , [ 2061379749, 1640576439, 1757691577, 1474760595, 1592394909, 1174215055 ]
            , [ 1290801793, -1418998981, -1570324427, -1183720153, -1333995991 ]
            , [ -1889540349, -2041385971, -1656360673, -1807156719, -486304949 ]
            , [ -368142267, -249985705, -132870567, -952647821, -835013507, -718427793 ]
            , [ -601841055, 1986918061, 2137062819, 1685577905, 1836772287, 1381620373 ]
            , [ 1532285339, 1078185097, 1229899655, 1040559837, 923313619, 740276417 ]
            , [ 621982671, 439452389, 322734571, 137073913, 19308535, -423803315 ]
            , [ -273658557, -190361519, -39167137, -1031181707, -880516741, -795640727 ]
            , [ -643926169, -1361764803, -1479011021, -1127282655, -1245576401 ]
            , [ -1964953083, -2081670901, -1728371687, -1846137065, 1305906550 ]
            , [ 1155237496, 1607244650, 1455525988, 1776460110, 1626319424, 2079897426 ]
            , [ 1928707164, 96392454, 213114376, 396673818, 514443284, 562755902 ]
            , [ 679998000, 865136418, 983426092, -586793578, -737462632, -820237430 ]
            , [ -971956092, -114159186, -264299872, -349698126, -500888388, -1787927066 ]
            , [ -1671205144, -2022411270, -1904641804, -1319482914, -1202240816 ]
            , [ -1556062270, -1437772596, -321194175, -438830001, -20913827, -137500077 ]
            , [ -923870343, -1042034569, -621490843, -738605461, -1531793615 ]
            , [ -1379949505, -1230456531, -1079659997, -2138668279, -1987344377 ]
            , [ -1835231979, -1684955621, 2081048481, 1963412655, 1846563261, 1729977011 ]
            , [ 1480485785, 1362321559, 1243905413, 1126790795, 878845905, 1030690015 ]
            , [ 645401037, 796197571, 274084841, 425408743, 38544885, 188821243 ]
            , [ -681472870, -563312748, -981755258, -864644728, -212492126, -94852180 ]
            , [ -514869570, -398279248, -1626745622, -1778065436, -1928084746 ]
            , [ -2078357000, -1153566510, -1305414692, -1457000754, -1607801408 ]
            , [ 1202797690, 1320957812, 1437280870, 1554391400, 1669664834, 1787304780 ]
            , [ 1906247262, 2022837584, 265905162, 114585348, 499347990, 349075736 ]
            , [ 736970802, 585122620, 972512814, 821712160, -1699282452, -1816524062 ]
            , [ -2001922064, -2120213250, -1098699308, -1215420710, -1399243832 ]
            , [ -1517014842, -757114468, -606973294, -1060810880, -909622130, -152341084 ]
            , [ -1671510, -453942344, -302225226, 174567692, 57326082, 410887952 ]
            , [ 292596766, 777231668, 660510266, 1011452712, 893681702, 1108339068 ]
            , [ 1258480242, 1343618912, 1494807662, 1715193156, 1865862730, 1948373848 ]
            , [ 2100090966, -1593017801, -1476300487, -1290376149, -1172609243 ]
            , [ -2059905521, -1942659839, -1759363053, -1641067747, -379313593 ]
            , [ -529979063, -75615141, -227328171, -850391425, -1000536719, -548792221 ]
            , [ -699985043, 836553431, 953270745, 600235211, 718002117, 367585007 ]
            , [ 484830689, 133361907, 251657213, 2041877159, 1891211689, 1806599355 ]
            , [ 1654886325, 1568718495, 1418573201, 1335535747, 1184342925 ]
            ]
