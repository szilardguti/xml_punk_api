(: Összeszámolja hány új sört főztek az egyes években, majd ezeket egy XML állományba rendezi :)
xquery version '3.1';

(: import schema default element namespace "" at "04-first-brew-by-years.xsd"; :)

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:indent "yes";

let $beers := fn:json-doc("../all_api_data.json")?*,
    $years :=
    for $year in $beers?first_brewed
    return
        if (string-length($year) eq 7) then
            substring($year, 4, 4)
        else
            $year

return
    document {
        <years all="{$years => count()}">
            {
                for $year in $years
                    group by $groupedYear := $year
                    order by $groupedYear
                return
                    <year
                        value="{$groupedYear}"
                    >{count($year)}</year>
            }
        </years>
    }