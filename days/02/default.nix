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

  raw = readFile ./input;

  removeTrailingNewline = str: substring 0 ((stringLength str) - 1) str;

  abs = n: if n < 0 then -n else n;
  range = list: genList (n: n) (length list - 1);

  remove =
    pos: list:
    let
      len = length list;
      front = sublist 0 pos list;
      back = sublist (pos + 1) (len - pos - 1) list;
    in
    front ++ back;

  parseInput =
    input:
    removeTrailingNewline input
    |> split "\n"
    |> filter isString
    |> map (line: map fromJSON (filter isString (split " " line)));

  isMonotonic =
    row:
    let
      indices = range row;
      increasing = foldl' (acc: i: acc && (elemAt row i) >= (elemAt row (i + 1))) true indices;
      decreasing = foldl' (acc: i: acc && (elemAt row i) <= (elemAt row (i + 1))) true indices;
    in
    increasing || decreasing;

  isSafe =
    item1: item2:
    let
      diff = abs (item1 - item2);
    in
    diff > 0 && diff <= 3;

  checkRowSafety =
    row:
    if !isMonotonic row then
      false
    else
      foldl' (acc: i: acc && isSafe (elemAt row i) (elemAt row (i + 1))) true (range row);

  checkRowSafetyWithProtection =
    row:
    any (
      i:
      let
        filteredRow = filter (_: true) (remove i row);
      in
      isMonotonic filteredRow
      && foldl' (acc: j: acc && isSafe (elemAt filteredRow j) (elemAt filteredRow (j + 1))) true (
        range filteredRow
      )
    ) (genList (x: x) (length row));

  count = pred: foldl' (c: x: if pred x then c + 1 else c) 0;
  countTrue = count (inp: inp);

  checkSafetyPart1 = x: countTrue (map checkRowSafety x);
  checkSafetyPart2 = x: countTrue (map checkRowSafetyWithProtection x);

  solve = f: input: f (parseInput input);
in
{
  part1 = solve checkSafetyPart1 raw;
  part2 = solve checkSafetyPart2 raw;
}
