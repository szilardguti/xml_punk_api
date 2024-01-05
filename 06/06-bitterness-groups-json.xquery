(: A söröket keseűség (IBU szám) alapján 3+1 csoportba osztja, majd ezeket átalakított formában, 
kategórián belül ID szerint növekvő sorrendbe egy JSON asszociatív tömbbe menti :)
xquery version '3.1';

declare boundary-space preserve;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:indent "yes";

declare function local:transformBeer($beer as map(*)) as map(*)
{
    let $ibu := $beer?ibu,
        $name := $beer?name,
        $id := $beer?id,
        $desc := $beer?description
    return
        map
        {
            "id": $id,
            "name": $name,
            "ibu": if ($ibu => fn:empty() => fn:not()) then
                $ibu
            else
                "not present",
            "desc": text {$desc}
        }
};

declare function local:generateCategoryMap($values as map(*)*) as map(*)
{
    let $count := fn:count($values)
    return
        ordered {
            map {
                "count": $count,
                "values": array
                {
                    $values ! local:transformBeer(.)
                }
            }
        }

};

declare function local:sanitizeName($name as xs:string) as xs:string
{
    let $sanitizedName := fn:lower-case($name) => fn:replace("\s+", "_")
    return
        $sanitizedName
};


let $beers := fn:json-doc("../all_api_data.json")?*,
    $light := $beers[?ibu lt 41],
    $medium := $beers[?ibu gt 40 and ?ibu lt 81],
    $bitter := $beers[?ibu gt 80],
    $none := $beers[?ibu => fn:empty()]
return
    map {
        
        local:sanitizeName("Map Of Bitterness"): map {
            local:sanitizeName("No data"): local:generateCategoryMap($none),
            local:sanitizeName("Minimal Bitterness"): local:generateCategoryMap($light),
            local:sanitizeName("Normal Bitterness"): local:generateCategoryMap($medium),
            local:sanitizeName("High Bitterness"): local:generateCategoryMap($bitter)
        }
    }
