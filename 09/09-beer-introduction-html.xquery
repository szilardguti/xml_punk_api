(: A sörököt leszűrő, hogy csak azok maradjanak, amiknek megvan az összes szükséges adat, amit a weboldalon megjelenít.
   A weblap arra szolgál, hogy rövid képpek ellátott bemutatót adjon a sörökről. Jelenleg az első 10 megfelelő sörröl készül az összefoglaló
   A sörök leírásának háttér színe a sör színétől függően változik :)
xquery version '3.1';

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:indent "yes";
declare option output:html-version "5.0";


let $beers := fn:json-doc("../all_api_data.json")?*,
    $validBeers := $beers[fn:not(fn:empty(?name))
    and fn:not(fn:empty(?description))
    and fn:not(fn:empty(?tagline))
    and fn:not(fn:empty(?image_url))
    and fn:not(fn:empty(?contributed_by))
    and fn:not(fn:empty(?abv))
    and fn:not(fn:empty(?ibu))
    and fn:not(fn:empty(?ebc))
    and fn:not(fn:empty(?ph))] => fn:subsequence(1, 10)
return
    document {
        <html
            lang="en">
            <head>
                <meta
                    charset="UTF-8"/>
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1.0"/>
                <title>Document</title>
                <link
                    rel="stylesheet"
                    href="https://fonts.googleapis.com/css2?family=Brewmaster"
                />
                <link
                    rel="stylesheet"
                    href="09-beer_introduction_html.css"/>
            </head>
            <body>
                {
                    for $beer in $validBeers
                    return
                        <div
                            class="bg {
                                    let $ebc := $beer?ebc
                                    return
                                        if ($ebc <= 16) then
                                            "light"
                                        else
                                            if ($ebc > 16 and $ebc < 40) then
                                                "medium"
                                            else
                                                "dark"
                                }">
                            <table>
                                <thead>
                                    <tr>
                                        <th
                                            colspan="2">{$beer?name}<br/></th>
                                        <th
                                            style="text-align: right">{text {"#" || $beer?id}}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td
                                            rowspan="7"
                                            class="image">
                                            <img
                                                src="{$beer?image_url}"
                                                alt="image of the beer"
                                            />
                                        </td>
                                        <td
                                            colspan="2"
                                            class="desc">{$beer?description}</td>
                                    </tr>
                                    <tr>
                                        <td
                                            colspan="2"
                                            style="text-align: center">{$beer?tagline}<br/></td>
                                    </tr>
                                    <tr>
                                        <td>contributed by:</td>
                                        <td>{$beer?contributed_by}</td>
                                    </tr>
                                    <tr>
                                        <td>abv:</td>
                                        <td>{$beer?abv}</td>
                                    </tr>
                                    <tr>
                                        <td>ibu:</td>
                                        <td>{$beer?ibu}</td>
                                    </tr>
                                    <tr>
                                        <td>ebc:</td>
                                        <td>{$beer?ebc}</td>
                                    </tr>
                                    <tr>
                                        <td>ph:</td>
                                        <td>{$beer?ph}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                }
            </body>
        </html>
    }