let
  inherit (builtins)
    split
    filter
    genList
    length
    stringLength
    map
    substring
    fromJSON
    isString
    elemAt
    foldl'
    any
    readFile
    all
    ;

  # from nixpkgs lib
  sublist =
    start: count: list:
    let
      len = length list;
    in
    genList (n: elemAt list (n + start)) (
      if start >= len then
        0
      else if start + count > len then
        len - start
      else
        count
    );
  drop = count: list: sublist count (length list) list;
  take = count: sublist 0 count;

  raw = readFile ./input;

  removeTrailingNewline = str: substring 0 (stringLength str - 1) str;

  parseInput =
    input:
    input
    |> removeTrailingNewline
    |> split "\n"
    |> filter isString
    |> map (line: map fromJSON (filter isString (split " " line)));

  id = x: x;
  abs = n: if n < 0 then -n else n;
  range = list: genList id (length list - 1);

  isMonotonic =
    row:
    let
      indices = genList id (length row - 1);
    in
    all (i: elemAt row i <= elemAt row (i + 1)) indices
    || all (i: elemAt row i >= elemAt row (i + 1)) indices;

  isSafe =
    item1: item2:
    let
      diff = abs (item1 - item2);
    in
    diff > 0 && diff <= 3;

  checkRowSafety =
    row: isMonotonic row && all (i: isSafe (elemAt row i) (elemAt row (i + 1))) (range row);

  checkRowSafetyWithProtection =
    row:
    any (
      i:
      let
        filteredRow = filter (_: true) (take i row ++ drop (i + 1) row);
      in
      isMonotonic filteredRow
      && all (j: isSafe (elemAt filteredRow j) (elemAt filteredRow (j + 1))) (range filteredRow)
    ) (genList id (length row));

  count = pred: foldl' (c: x: if pred x then c + 1 else c) 0;
  countTrue = count id;

  checkSafetyPart1 = x: countTrue (map checkRowSafety x);
  checkSafetyPart2 = x: countTrue (map checkRowSafetyWithProtection x);

  solve = f: input: f (parseInput input);
in
{
  part1 = solve checkSafetyPart1 raw;
  part2 = solve checkSafetyPart2 raw;
}
