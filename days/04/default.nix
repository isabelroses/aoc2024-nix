let
  inherit (builtins)
    length
    head
    filter
    substring
    split
    stringLength
    isString
    elemAt
    foldl'
    genList
    readFile
    ;

  # from nixpkgs lib
  range = first: last: if first > last then [ ] else genList (n: first + n) (last - first + 1);

  raw = readFile ./input;

  # common parsing functions for the input
  removeTrailingNewline = str: substring 0 ((stringLength str) - 1) str;
  parseLine = input: split "" input |> filter (c: isString c && c != "");
  parseInput = input: removeTrailingNewline input |> split "\n" |> filter isString |> map parseLine;

  # solver function that takes a function and the raw input
  solve = f: input: f (parseInput input);

  ## part 1
  # Helper to check if a specific direction matches "XMAS"
  checkDirection =
    wordSearch: n: m: target: i: j: di: dj:
    foldl' (
      acc: k:
      let
        ni = i + di * k;
        nj = j + dj * k;
        isValid =
          ni >= 0 && ni < n && nj >= 0 && nj < m && elemAt (elemAt wordSearch ni) nj == elemAt target k;
      in
      acc && isValid
    ) true (range 0 3);

  # Count occurrences of "XMAS" in all directions starting from a given cell
  countFromCell =
    wordSearch: n: m: target: i: j:
    foldl' (
      acc: dir: acc + (if checkDirection wordSearch n m target i j dir.di dir.dj then 1 else 0)
    ) 0 directions;

  # Main function to count "XMAS" in the word search
  part1 =
    wordSearch:
    let
      n = length wordSearch;
      m = length (elemAt wordSearch 0);
    in
    foldl' (
      acc: i:
      acc
      + foldl' (
        lineAcc: j:
        lineAcc
        + (if elemAt (elemAt wordSearch i) j == "X" then countFromCell wordSearch n m target i j else 0)
      ) 0 (range 0 (m - 1))
    ) 0 (range 0 (n - 1));

  # well defined constants for directions
  target = [
    "X"
    "M"
    "A"
    "S"
  ];

  directions = [
    {
      di = 0;
      dj = 1;
    } # Horizontal right
    {
      di = 0;
      dj = -1;
    } # Horizontal left
    {
      di = 1;
      dj = 0;
    } # Vertical down
    {
      di = -1;
      dj = 0;
    } # Vertical up
    {
      di = 1;
      dj = 1;
    } # Diagonal down-right
    {
      di = -1;
      dj = -1;
    } # Diagonal up-left
    {
      di = 1;
      dj = -1;
    } # Diagonal down-left
    {
      di = -1;
      dj = 1;
    } # Diagonal up-right
  ];

  ## part2
  hasXmas =
    i: j: lines: n: m:
    if !(i >= 1 && i < n - 1 && j >= 1 && j < m - 1) then
      false
    else if (elemAt (elemAt lines i) j) != "A" then
      false
    else
      let
        diag1 = (elemAt (elemAt lines (i - 1)) (j - 1)) + (elemAt (elemAt lines (i + 1)) (j + 1));
        diag2 = (elemAt (elemAt lines (i - 1)) (j + 1)) + (elemAt (elemAt lines (i + 1)) (j - 1));
      in
      (diag1 == "MS" || diag1 == "SM") && (diag2 == "MS" || diag2 == "SM");

  part2 =
    input:
    let
      n = length input;
      m = length (head input);
      indices = genList (i: i) n;
      jndices = genList (i: i) m;
    in
    foldl' (
      acc: i: foldl' (innerAcc: j: if hasXmas i j input n m then innerAcc + 1 else innerAcc) acc jndices
    ) 0 indices;
in
{
  part1 = solve part1 raw;
  part2 = solve part2 raw;
}
