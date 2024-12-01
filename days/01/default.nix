let
  lib = import ../../getlib.nix;

  inherit (builtins)
    map
    filter
    split
    isString
    fromJSON
    bitAnd
    isInt
    sort
    length
    lessThan
    add
    foldl'
    ;

  raw = builtins.readFile ./input;

  parseInput =
    input:
    let
      allNums = map fromJSON (filter (x: (isString x) && x != "") (split " |\n" input));

      ziped = lib.lists.zipLists (lib.range 0 (length allNums)) allNums;

      leftList = map (x: if ((bitAnd x.fst 1) == 0) then x.snd else null) ziped;
      rightList = map (x: if ((bitAnd x.fst 1) == 1) then x.snd else null) ziped;
    in
    {
      leftList = filter isInt leftList;
      rightList = filter isInt rightList;
    };

  abs = n: if n < 0 then -n else n;
  srtlt = list: sort lessThan list;

  calculateDistance =
    leftList: rightList:
    let
      sortedLeft = srtlt leftList;
      sortedRight = srtlt rightList;
      distances = lib.lists.zipListsWith (l: r: abs (l - r)) sortedLeft sortedRight;
    in
    foldl' add 0 distances;

  # part 2
  calculateSimilairty =
    leftList: rightList:
    let
      similarities = map (l: l * (lib.lists.count (x: x == l) rightList)) leftList;
    in
    foldl' add 0 similarities;

  solve =
    f: input:
    let
      parsed = parseInput input;
    in
    f parsed.leftList parsed.rightList;
in
{
  part1 = solve calculateDistance raw;
  part2 = solve calculateSimilairty raw;
}
