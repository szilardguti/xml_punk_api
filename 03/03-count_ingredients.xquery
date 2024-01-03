(: A receptekben előírt egyes alapanyagok (komló, élesztő, maláta) említésének számának összeszámlálása.
   Az alapanyagok megfelelő XML elemben jelennek meg, előfordulás szerint csökkenően:)
xquery version '3.1';

import schema default element namespace "" at "03-count_ingredients.xsd";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:indent "yes";

let $beers := fn:json-doc("../all_api_data.json")?*,
    $ingredients := $beers?ingredients,
    $hops := $ingredients?hops?*,
    $yeasts := $ingredients?yeast,
    $malts := $ingredients?malt?*
return 
    document {
    <ingredients>
        <hops all="{fn:count($hops)}">
            {
                for $hop in fn:distinct-values($hops?name)
                let $count := fn:count($hops?name[. = $hop])
                order by $count descending
                return 
                <hop count="{$count}">
                    {$hop}
                </hop>
            }
        </hops>
        <yeasts all="{fn:count($yeasts)}">
            {
                for $yeast in fn:distinct-values($yeasts)
                let $count := fn:count($yeasts[. = $yeast])
                order by $count descending
                return 
                <yeast count="{$count}">
                    {$yeast}
                </yeast>
            }
        </yeasts>
        <malts all="{fn:count($malts)}">
            {
                for $malt in fn:distinct-values($malts?name)
                let $count := fn:count($malts?name[. = $malt])
                order by $count descending
                return 
                <malt count="{$count}">
                    {$malt}
                </malt>
            }
        </malts>
    </ingredients>
}