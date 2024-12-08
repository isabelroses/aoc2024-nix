let
  inherit (builtins)
    map
    split
    filter
    isString
    elemAt
    foldl'
    mapAttrs
    fromJSON
    any
    genList
    mul
    length
    add
    attrNames
    ;

  range = first: last: if first > last then [ ] else genList (n: first + n) (last - first + 1);
  filterAttrs = pred: set: removeAttrs set (filter (name: !pred name set.${name}) (attrNames set));

  raw = builtins.readFile ./input;
  # raw = ''
  #   190: 10 19
  #   3267: 81 40 27
  #   83: 17 5
  #   156: 15 6
  #   7290: 6 8 6 15
  #   161011: 16 10 13
  #   192: 17 8 14
  #   21037: 9 7 18 13
  #   292: 11 6 16 20
  # '';

  parseInput =
    input:
    input
    |> split "\n"
    |> filter (x: isString x && x != "")
    |> map (
      line:
      let
        lt = split ": " line;
        val = elemAt lt 2 |> split " " |> filter isString |> map fromJSON;
      in
      {
        ${elemAt lt 0} = val;
      }
    )
    |> foldl' (a: b: a // b) { };

  applyOperators =
    numbers: operators:
    let
      len = length numbers - 1;
    in
    foldl' (
      acc: i:
      if i == 0 then
        elemAt numbers i
      else
        let
          operator = elemAt operators (i - 1);
          num = elemAt numbers i;
        in
        if operator == "add" then
          add acc num
        else if operator == "mul" then
          mul acc num
        else if operator == "concat" then
          fromJSON (toString acc + toString num)
        else
          throw "Unknown operator"
    ) 0 (range 0 len);

  generateOperators =
    n:
    if n == 0 then
      [ [ ] ]
    else
      let
        tl = generateOperators (n - 1);
      in
      (map (x: [ "add" ] ++ x) tl) ++ (map (x: [ "mul" ] ++ x) tl);

  generateOperatorsP2 =
    n:
    if n == 0 then
      [ [ ] ]
    else
      let
        tl = generateOperatorsP2 (n - 1);
      in
      (map (x: [ "add" ] ++ x) tl) ++ (map (x: [ "mul" ] ++ x) tl) ++ (map (x: [ "concat" ] ++ x) tl);

  buildPermutations =
    input:
    let
      operatorCombinations = generateOperators (length input - 1);
    in
    map (ops: applyOperators input ops) operatorCombinations;

  buildPermutationsP2 =
    input:
    let
      operatorCombinations = generateOperatorsP2 (length input - 1);
    in
    map (ops: applyOperators input ops) operatorCombinations;

  isPossible = target: numbers: any (x: x == fromJSON target) (buildPermutations numbers);
  isPossibleP2 = target: numbers: any (x: x == fromJSON target) (buildPermutationsP2 numbers);

  cal =
    input: f: mapAttrs f input |> filterAttrs (k: v: v) |> attrNames |> map fromJSON |> foldl' add 0;

  part1 = input: cal input isPossible;
  part2 = input: cal input isPossibleP2;

  solve = f: input: f (parseInput input);
in
{
  part1 = solve part1 raw;
  part2 = solve part2 raw;
}
