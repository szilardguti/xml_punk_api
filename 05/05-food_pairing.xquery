(: Az egyes ajánlott ételekhoz felsorolja az azokhoz illő söröket. XML formátumba menti le, sörök száma szerint csökkenő sorrendben :)
xquery version '3.1';

import schema default element namespace "" at "05-food_pairing.xsd";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:indent "yes";

declare function local:getBeerElements($foodGroup as xs:string, $beers as map(*)*) as element()* {
    for $beer in $beers
        where some $pairing in $beer?food_pairing?*
            satisfies $pairing eq $foodGroup
    return
        element beer {
            attribute id {$beer?id}, $beer?name
        }
};

let $beers := fn:json-doc("../all_api_data.json")?*,
    $foods := $beers?food_pairing => array:flatten()
return
    validate {
        document {
            <foodPairings>
                {
                    for $food in $foods
                        group by $foodGroup := $food
                        order by fn:count($food) descending
                    return
                        element food {
                            attribute name {$foodGroup},
                            if (fn:count($food) > 1) then
                                element beers {local:getBeerElements($foodGroup, $beers)}
                            else
                                local:getBeerElements($foodGroup, $beers)
                        }
                }
            </foodPairings>
        }
    }