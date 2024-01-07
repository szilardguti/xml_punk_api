(: Az JSON-ból elérhető adatokat átalakítja XML formátumba
   Első futtatásnál hibát dobhat, az API-ból kinyert adatok néhol hibásak, itt egy sörnek van helytelenül megadva a PH értéke
   :)
xquery version '3.1';

import schema default element namespace "" at "02-transform_data_to_xml.xsd";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:indent "yes";

let $beers := fn:json-doc("../all_api_data.json")?*
return
    validate {
        document
        {
            <beers>
                {
                    for $beer in $beers
                    let $method := $beer?method
                    return
                        <beer
                            id="{$beer?id}">
                            <name>{$beer?name}</name>
                            <tagline>{$beer?tagline}</tagline>
                            <firstBrewed>{$beer?first_brewed}</firstBrewed>
                            <description>{$beer?description}</description>
                            <contributedBy>{$beer?contributed_by}</contributedBy>
                            <attenuationLevel>{$beer?attenuation_level}</attenuationLevel>
                            <phLevel>{$beer?ph}</phLevel>
                            <method>
                                <mashTemperatures>
                                    {
                                        for $mashTemp in $method?mash_temp?*
                                        return
                                            <mashTemperature>
                                                <duration>{$mashTemp?duration}</duration>
                                                <value
                                                    unit="{$mashTemp?temp?unit}">{$mashTemp?temp?value}</value>
                                            </mashTemperature>
                                    }
                                </mashTemperatures>
                                <fermentation>
                                    <value
                                        unit="{$method?fermentation?temp?unit}">{$method?fermentation?temp?value}</value>
                                </fermentation>
                                <twist>{$method?twist}</twist>
                            </method>
                            <targetOg>{$beer?target_og}</targetOg>
                            <targetFg>{$beer?target_fg}</targetFg>
                            <imageUrl>{$beer?image_url}</imageUrl>
                            <boilVolume
                                unit="{$beer?boil_volume?unit}">{$beer?boil_volume?value}</boilVolume>
                            <volume
                                unit="{$beer?volume?unit}">{$beer?volume?value}</volume>
                            <ebc>{$beer?ebc}</ebc>
                            <srm>{$beer?srm}</srm>
                            <abv>{$beer?abv}</abv>
                            <ibu>{$beer?ibu}</ibu>
                            <foodPairings>
                                {
                                    for $food in array:flatten($beer?food_pairing)
                                    return
                                        <food>{$food}</food>
                                }
                            </foodPairings>
                            <ingredients>
                                <hops>
                                    {
                                        let $hops := $beer?ingredients?hops?*
                                        for $hop in $hops
                                        return
                                            <hop>
                                                <name>{$hop?name}</name>
                                                <add>{$hop?add}</add>
                                                <amount
                                                    unit="{$hop?amount?unit}">{$hop?amount?value}</amount>
                                                <attribute>{$hop?attribute}</attribute>
                                            </hop>
                                    }
                                </hops>
                                <yeast>{$beer?ingredients?yeast}</yeast>
                                <malts>
                                    {
                                        let $malts := $beer?ingredients?malt?*
                                        for $malt in $malts
                                        return
                                            <malt>
                                                <name>{$malt?name}</name>
                                                <amount
                                                    unit="{$malt?amount?unit}">{$malt?amount?value}</amount>
                                            </malt>
                                    }
                                </malts>
                            </ingredients>
                            <brewersTips>{$beer?brewers_tips}</brewersTips>
                        </beer>
                }
            
            </beers>
        }
    }