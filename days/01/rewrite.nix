let
  inherit (builtins)
    map
    filter
    split
    isString
    fromJSON
    bitAnd
    sort
    length
    lessThan
    add
    foldl'
    elemAt
    genList
    ;

  # vendored and or partly altered nixpkgs lib, beacuse i wanted speeeeeeed
  count = pred: foldl' (c: x: if pred x then c + 1 else c) 0;
  zipListsWith =
    f: fst: snd:
    genList (n: f (elemAt fst n) (elemAt snd n)) (length snd);

  # all self written code actualy starts here
  raw = builtins.readFile ./input;

  # glorified lib.lists.zipLists
  index =
    l:
    let
      len = genList (n: n) (length l);
    in
    map (n: {
      index = elemAt len n;
      value = elemAt l n;
    }) len;

  parseInput =
    input:
    let
      nums = index (map fromJSON (filter (x: isString x && x != "") (split "([[:space:]]+)" input)));
    in
    foldl'
      (
        acc: x:
        let
          side = if bitAnd x.index 1 == 0 then "left" else "right";
        in
        acc // { ${side} = acc.${side} ++ [ x.value ]; }
      )
      {
        left = [ ];
        right = [ ];
      }
      nums;

  # nix builtins doesn't have abs
  abs = n: if n < 0 then -n else n;
  # small helper on sort
  srtlt = list: sort lessThan list;

  calculateDistance =
    left: right:
    let
      sortedLeft = srtlt left;
      sortedRight = srtlt right;
      distances = zipListsWith (l: r: abs (l - r)) sortedLeft sortedRight;
    in
    foldl' add 0 distances;

  # part 2
  calculateSimilairty =
    left: right:
    let
      similarities = map (l: l * (count (x: x == l) right)) left;
    in
    foldl' add 0 similarities;

  # very nice and generic
  solve =
    f: input:
    let
      parsed = parseInput input;
    in
    f parsed.left parsed.right;
in
{
  part1 = solve calculateDistance raw;
  part2 = solve calculateSimilairty raw;
}
