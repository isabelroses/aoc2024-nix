let
  inherit (builtins)
    readFile
    split
    map
    filter
    isString
    substring
    stringLength
    fromJSON
    elemAt
    div
    length
    foldl'
    add
    any
    genList
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

  findFirstIndex =
    find: list:
    foldl' (index: e: if index < 0 then if (find == e) then -index - 1 else index - 1 else index) (
      -1
    ) list;

  raw = readFile ./input;

  removeTrailingNewline = str: substring 0 ((stringLength str) - 1) str;
  processInput =
    input:
    removeTrailingNewline input
    |> split "\n\n"
    |> filter isString
    |> map (part: part |> split "\n" |> filter isString);

  makeRulesAndUpdates =
    input:
    let
      rules =
        map (line: line |> split "\\|" |> filter isString |> map fromJSON) (elemAt input 0)
        |> map (rule: {
          x = elemAt rule 0;
          y = elemAt rule 1;
        });
      updates = map (line: line |> split "," |> filter isString |> map fromJSON) (elemAt input 1);
    in
    {
      inherit rules updates;
    };

  contains = item: list: any (x: x == item) list;

  checkOrder =
    update:
    { x, y }: # rule
    if contains x update && contains y update then
      let
        xIndex = findFirstIndex x update;
        yIndex = findFirstIndex y update;
      in
      xIndex < yIndex
    else
      true;

  isCorrectOrder = { update, rules }: all (rule: checkOrder update rule) rules;

  getMiddle = arr: elemAt arr (div (length arr) 2);

  proccessUpdates =
    { updates, rules }:
    foldl' (
      acc: update: add acc (if isCorrectOrder { inherit update rules; } then getMiddle update else 0)
    ) 0 updates;

  ajustOrder =
    update:
    { x, y }: # rule
    if contains x update && contains y update then
      let
        xIndex = findFirstIndex x update;
        yIndex = findFirstIndex y update;
      in
      if xIndex < yIndex then swap update xIndex yIndex else update
    else
      update;

  swap =
    list: idx1: idx2:
    let
      elem1 = elemAt list idx1;
      elem2 = elemAt list idx2;

      front = sublist 0 idx1 list;
      inject1 = [ elem2 ];
      middle = sublist (idx1 + 1) (idx2 - idx1 - 1) list;
      inject2 = [ elem1 ];
      back = sublist (idx2 + 1) (length list - idx2 - 1) list;
    in
    front ++ inject1 ++ middle ++ inject2 ++ back;

  proccessUpdates2 =
    { updates, rules }:
    foldl' (
      acc: update:
      add acc (
        if !isCorrectOrder { inherit update rules; } then
          getMiddle (foldl' (prev: rule: ajustOrder prev rule) update rules)
        else
          0
      )
    ) 0 updates;

  solve =
    f: input:
    let
      processed = makeRulesAndUpdates (processInput input);
    in
    f { inherit (processed) rules updates; };
in
{
  part1 = solve proccessUpdates raw;
  part2 = solve proccessUpdates2 raw;
}
