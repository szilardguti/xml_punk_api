(: A sörök leírásából összeszedett szavakhoz kiszámítja hányszor szerepelnek. 
   A JSON állományban már csak a 10 vagy annál többször szereplő szavak kerülnek, valamint belekerül, hogy hány egyedi szó van a leírásokban
   vagy hogy hány szóból áll az összes leírás együttesen, ezek szintén a kiszűrt szavakra is elkészülnek :)
xquery version '3.1';

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:indent "yes";



let $beers := fn:json-doc("../all_api_data.json")?*,
    $words := $beers?description[fn:empty(.) => fn:not()]
    ! fn:tokenize(., '[\s\p{P}]+')[. ne '']
    ! fn:lower-case(.),
    $wordCounts as map(*)* :=
    for $uniqueWord in distinct-values($words)
    return
        map {$uniqueWord: fn:count($words[. = $uniqueWord])},
    $filteredWordCounts := $wordCounts[?* >= 10]
return
    map
    {
        "uniqe_word_count": fn:count($wordCounts),
        "filtered_uniqe_word_count": fn:count($filteredWordCounts),
        "all_word_count": fn:sum($wordCounts?*),
        "filtered_all_word_count": fn:sum($filteredWordCounts?*),
        "words": array:sort(array { $filteredWordCounts } ,(), function($fword) { $fword?* }) => array:reverse()
    }