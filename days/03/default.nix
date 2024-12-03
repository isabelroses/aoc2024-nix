let
  inherit (builtins)
    split
    filter
    isList
    map
    fromJSON
    readFile
    concatLists
    mul
    add
    foldl'
    elemAt
    match
    ;

  raw = readFile ./input;

  parseInputPart1 =
    input: filter isList (split "mul\\(([0-9]+),([0-9]+)\\)" input) |> map (list: map fromJSON list);

  calculate1 = input: map (list: mul (elemAt list 0) (elemAt list 1)) input |> foldl' add 0;

  solve1 = input: calculate1 (parseInputPart1 input);

  parseInputPart2 =
    input:
    split "(do\\(\\)|don't\\(\\)|mul\\([0-9]+,[0-9]+\\))" input
    |> filter isList
    |> concatLists
    |> map processPart;

  calculate2 =
    input:
    (foldl' process {
      enabled = true;
      sum = 0;
    } input).sum;

  processPart =
    part:
    if match "^do\\(\\)$" part != null then
      { type = "do"; }
    else if match "^don't\\(\\)$" part != null then
      { type = "don't"; }
    else if match "^mul\\([0-9]+,[0-9]+\\)$" part != null then
      {
        type = "mul";
        values = split "([0-9]+)" part |> filter isList |> concatLists |> map fromJSON;
      }
    else
      null;

  process =
    state: instruction:
    if instruction.type == "do" then
      {
        enabled = true;
        inherit (state) sum;
      }
    else if instruction.type == "don't" then
      {
        enabled = false;
        inherit (state) sum;
      }
    else if instruction.type == "mul" && state.enabled then
      {
        enabled = true;
        sum = state.sum + (mul (elemAt instruction.values 0) (elemAt instruction.values 1));
      }
    else
      state;

  solve2 = input: calculate2 (parseInputPart2 input);
in
{
  part1 = solve1 raw;
  part2 = solve2 raw;
}
