let
  inherit (builtins)
    split
    filter
    isList
    concatLists
    map
    fromJSON
    stringLength
    substring
    bitAnd
    mapAttrs
    foldl'
    match
    zipAttrsWith
    genList
    head
    attrValues
    add
    ;

  parseInt =
    str:
    let
      lst = match "0*(-?[[:digit:]]+)" str;
      ret = head lst;
      isZero = match "0+" ret == [ ];
    in
    if isZero then "0" else ret;

  raw = "125 17";

  parsed =
    split "([0-9]+)" raw
    |> filter isList
    |> concatLists
    |> map (v: {
      ${v} = 1;
    })
    |> foldl' (a: b: a // b) { };

  splitNumber =
    str:
    let
      len = stringLength str;
      s1Raw = substring 0 (len / 2) str;
      s2Raw = substring (len / 2) len str;
      s1 = parseInt s1Raw;
      s2 = parseInt s2Raw;
    in
    {
      inherit s1 s2;
    };

  blink =
    stones:
    let
      init = mapAttrs (
        k: v:
        let
          kInt = fromJSON k;
        in
        if k == "0" then
          { "1" = v; }
        else if (bitAnd (stringLength k) 1) == 0 then
          let
            halves = splitNumber k;
          in
          if halves.s1 == halves.s2 then
            { ${halves.s1} = v * 2; }
          else
            {
              ${halves.s1} = v;
              ${halves.s2} = v;
            }
        else
          let
            id = toString (kInt * 2024);
          in
          {
            ${id} = v;
          }
      ) stones;
    in
    zipAttrsWith (_: v: foldl' add 0 v) (attrValues init);

  out = itr: foldl' (a: _: blink a) parsed (genList (x: x) itr);
  count = out: foldl' add 0 (attrValues out);

  solve = itr: count (out itr);
in
{
  part1 = solve 25;
  part2 = solve 75;
}
