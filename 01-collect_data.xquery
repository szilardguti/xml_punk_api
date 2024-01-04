(: A Punk API-n keresztül elérhető összes adat kinyerése lapozással :)
xquery version '3.1';

import module namespace deik-utility = "http://www.inf.unideb.hu/xquery/utility"
at "https://arato.inf.unideb.hu/jeszenszky.peter/FejlettXML/lab/lab10/utility/utility.xquery";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:indent "yes";

declare function local:get-beer-data($page as xs:integer) {
    let $uri := deik-utility:add-query-params("https://api.punkapi.com/v2/beers",
    map {
        "page": $page,
        "per_page": 80
    })
    return
        fn:json-doc($uri)
};

declare function local:get-beers($page as xs:integer) {
    let $data := local:get-beer-data($page),
        $emptyArray := [ ]
    return 
        if (array:size($data) > 0) then
            array:join( ($data, local:get-beers($page + 1)) )
        else 
            $emptyArray
};

let $startingPage := 1
return
    local:get-beers($startingPage)