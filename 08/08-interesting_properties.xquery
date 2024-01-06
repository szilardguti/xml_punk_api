(: :)
xquery version '3.1';

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:indent "yes";


let $beers := fn:doc("../output/02-transform_data_to_xml.xml")/beers,
    
    $elementsWithUnit := $beers//*[@unit],
    $units := for $unit in $elementsWithUnit
    return
        data($unit/@unit),
    $unitTypes := fn:distinct-values($units),
    $strongestBeers := $beers/beer[abv = max($beers//abv)],
    $lastBeer := $beers/beer[last()],
    $contributors := distinct-values($beers//contributedBy/text()),
    $fermentationCelsiusTemp := $beers/child::beer/descendant::fermentation/value[@unit = "celsius"]/number(),
    $highestFermentationCelsiusTempBeer := $beers/beer[method/fermentation/value[@unit = "celsius"]/number() = max($fermentationCelsiusTemp)]
return
    map
    {
        "unit_types": array {$unitTypes} => array:sort(),
        "strongest_beer": array {
            for $beer in $strongestBeers
            return
                map {
                    "id": data($beer/@id),
                    "name": $beer/name/text(),
                    "abv": $beer/abv/string()
                }
        },
        "last_beer": map {
            "id": data($lastBeer/@id),
            "name": $lastBeer/name/text()
        },
        "contributors": array {$contributors},
        "contribution_numbers": array {
            for $contributor in $contributors
            return
                map {
                    $contributor => fn:replace("&lt;", "_") => fn:substring-after("_") => fn:replace("&gt;", "")
                    : count($beers//contributedBy[. = $contributor])
                }
        },
        "avarage_darkness": map {
            "avg_ebc": avg($beers/beer/ebc),
            "avg_srm": avg($beers/beer/srm)
        },
        "highest_fermentation_celsius": map {
            "name": $highestFermentationCelsiusTempBeer/name/string(),
            "temp": max($fermentationCelsiusTemp),
            "id": $highestFermentationCelsiusTempBeer/data(@id) => xs:int()
        },
        "8_abv_ids": array {$beers/beer/abv[. = 8]/../attribute::id ! data(.) ! xs:int(.) }
    }
