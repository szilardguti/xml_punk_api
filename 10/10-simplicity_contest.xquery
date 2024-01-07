(: Alkohol százelék szerint növekvő sorrendbe állított sörök között 3 elemes csoportokat képez.
   Ezekhez egy "egyszerűségi értéket" rendel, azaz megszámolja hány alapanyagból és lépésből áll. 
   Minél kevesebb ez az érték annál jobb helyezést ér el a sör a saját csoportjában.
   A rangsorolást a weblapon egy dobogót ábrázolva jeleníti meg, ahol a sörök neve és azonosítója látható az egyes fokokon :)
xquery version '3.1';

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:indent "yes";

declare function local:calculateSimplicity($beer as map(*)) as xs:integer*
{
    let $method := $beer?method?mash_temp => array:size(),
        $hops := $beer?ingredients?hops => array:size(),
        $malts := $beer?ingredients?malt => array:size(),
        $twist := if ($beer?method?twist => fn:empty() => fn:not()) then
            5
        else
            0
    return
        $method + $hops + $malts + $twist
};

declare function local:replaceAt($sequence as item()*, $index as xs:integer, $newValue as item()) as item()* {
    let $before := subsequence($sequence, 1, $index - 1)
    let $after := subsequence($sequence, $index + 1)
    return
        ($before, $newValue, $after)
};


let $beers := fn:json-doc("../all_api_data.json")?*,
    $windows := for tumbling window $window
    in fn:sort($beers, (), function ($beer) {
        $beer?abv
    })
        start at $i when fn:count($beers) > 0
        end at $j when $j - $i eq 2
    return
        array {$window?id},
    $pBeers := for $w in $windows
    let $wBeer := $beers[?id = $w]
    return
        array
        {
            map {
                "names": $wBeer?name,
                "ids": $wBeer?id,
                "points": $wBeer ! local:calculateSimplicity(.)
            }
        }
return
    document
    {
        <html
            lang="en">
            <head>
                <meta
                    charset="UTF-8"/>
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1.0"/>
                <title>Simplicity Contest</title>
                <link
                    rel="stylesheet"
                    href="https://fonts.googleapis.com/css2?family=Brewmaster"
                />
                <link
                    rel="stylesheet"
                    href="10-simplicity_contest.css"/>
            </head>
            <body>
                {
                    for $pBeer in $pBeers
                    let $points := $pBeer?*?points,
                        $firstIndex := fn:index-of($points, min($points))[1],
                        $points := local:replaceAt($points, $firstIndex, 1000),
                        $secondIndex := if ((min($points) = 1000) => fn:not()) then
                            fn:index-of($points, min($points))[1]
                        else
                            (),
                        $points := if ($secondIndex => fn:empty() => fn:not()) then
                            local:replaceAt($points, $secondIndex, 1000)
                        else
                            (),
                        $thirdIndex := if ((min($points) = 1000) => fn:not() and $points => fn:empty() => fn:not()) then
                            fn:index-of($points, min($points))[1]
                        else
                            ()
                    return
                        <div
                            class="bg">
                            {
                                let $secondIsPresent := fn:not(fn:empty($secondIndex))
                                return
                                    if ($secondIsPresent) then
                                        document {
                                            <table>
                                                <thead></thead>
                                                <tbody>
                                                    <tr>
                                                        <td
                                                            class="empty"></td>
                                                    </tr>
                                                    <tr>
                                                        <td
                                                            class="medal">&#x1F948;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>{array {$pBeer?*?names} => array:get($secondIndex)}</td>
                                                    </tr>
                                                    <tr>
                                                        <td>{text {"#" || array {$pBeer?*?ids} => array:get($secondIndex)}}</td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        }
                                    else
                                        ()
                            }
                            {
                                let $firstIsPresent := fn:not(fn:empty($firstIndex))
                                return
                                    if ($firstIsPresent) then
                                        document {
                                            <table>
                                                <thead></thead>
                                                <tbody>
                                                    <tr>
                                                        <td
                                                            class="medal">&#x1F947;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>{array {$pBeer?*?names} => array:get($firstIndex)}</td>
                                                    </tr>
                                                    <tr>
                                                        <td>{text {"#" || array {$pBeer?*?ids} => array:get($firstIndex)}}</td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        }
                                    else
                                        ()
                            }
                            {
                                let $thirdIsPresent := fn:not(fn:empty($thirdIndex))
                                return
                                    if ($thirdIsPresent) then
                                        document {
                                            <table>
                                                <thead></thead>
                                                <tbody>
                                                    <tr>
                                                        <td
                                                            class="empty"></td>
                                                    </tr>
                                                    <tr>
                                                        <td
                                                            class="empty"></td>
                                                    </tr>
                                                    <tr>
                                                        <td
                                                            class="medal">&#x1F949;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>{array {$pBeer?*?names} => array:get($thirdIndex)}</td>
                                                    </tr>
                                                    <tr>
                                                        <td>{text {"#" || array {$pBeer?*?ids} => array:get($thirdIndex)}}</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        }
                                    else
                                        ()
                            }
                        </div>
                }
            </body>
        </html>
    }