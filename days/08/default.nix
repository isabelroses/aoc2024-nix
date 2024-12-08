let
  inherit (builtins)
    readFile
    split
    filter
    isString
    map
    foldl'
    elemAt
    genList
    length
    head
    mapAttrs
    concatLists
    attrValues
    any
    ;

  # nixpkgs lib
  singleton = x: [ x ];
  range = first: last: if first > last then [ ] else genList (n: first + n) (last - first + 1);
  imap0 = f: list: genList (n: f n (elemAt list n)) (length list);

  raw = readFile ./input;

  isValidString = x: isString x && x != "";

  parseInput =
    input:
    input |> split "\n" |> filter isValidString |> map (line: split "" line |> filter isValidString);

  findPositions =
    input:
    let
      cols = length input - 1;
      rows = length (head input) - 1;
    in
    foldl' (
      acc: y:
      foldl' (
        innerAcc: x:
        let
          str = elemAt (elemAt input y) x;
        in
        if str != "." then
          if innerAcc ? ${str} then
            innerAcc
            // {
              ${str} =
                innerAcc.${str}
                ++ singleton {
                  inherit x y;
                };
            }
          else
            innerAcc
            // {
              ${str} = singleton {
                inherit x y;
              };
            }
        else
          innerAcc
      ) acc (range 0 cols)
    ) { } (range 0 rows);

  calculateAntinodes =
    nodes:
    let
      totalNodes = length nodes - 1;

      generateAntinodes =
        { x, y }: # self
        index: # other
        let
          other = elemAt nodes index;
          dx = 2 * (other.x - x);
          dy = 2 * (other.y - y);
        in
        {
          x = x + dx;
          y = y + dy;
        };

      nodeAntinodes = i: node: map (generateAntinodes node) (filter (n: n != i) (range 0 totalNodes));
    in
    concatLists (imap0 nodeAntinodes nodes);

  calculateAntinodesP2 =
    size: nodes:
    let
      totalNodes = length nodes - 1;

      generateAntinodes =
        { x, y }: # self
        index: # other
        let
          other = elemAt nodes index;
          dx = other.x - x;
          dy = other.y - y;

          extendToEdges =
            current:
            if current.x < 0 || current.y < 0 || current.x >= size.x || current.y >= size.y then
              [ ]
            else
              [ current ]
              ++ extendToEdges {
                x = current.x + dx;
                y = current.y + dy;
              };
        in
        extendToEdges {
          x = x + dx;
          y = y + dy;
        };

      nodeAntinodes = i: node: map (generateAntinodes node) (filter (n: n != i) (range 0 totalNodes));

      antinodes = concatLists (concatLists (imap0 nodeAntinodes nodes));
      final = foldl' (
        acc: antinode: if any (n: n == antinode) acc then acc else acc ++ singleton antinode
      ) [ ] antinodes;
    in
    final;

  removeOffGrid =
    size: nodes: filter ({ x, y }: x >= 0 && y >= 0 && x <= size.x && y <= size.y) nodes;

  part1 =
    input:
    let
      parsed = parseInput input;
      size = {
        y = length parsed - 1;
        x = length (head parsed) - 1;
      };
      nodes = findPositions parsed;
      antinodes = mapAttrs (n: v: calculateAntinodes v |> removeOffGrid size) nodes;
      mergedantinodes = foldl' (a: b: a ++ b) [ ] (attrValues antinodes);
      # we need to remove duplicates
      finalantinoes = foldl' (
        acc: antinode: if any (n: n == antinode) acc then acc else acc ++ singleton antinode
      ) [ ] mergedantinodes;
    in
    finalantinoes |> length;

  part2 =
    input:
    let
      parsed = parseInput input;
      size = {
        y = length parsed;
        x = length (head parsed);
      };
      nodes = findPositions parsed;
      antinodes = mapAttrs (n: v: calculateAntinodesP2 size v) nodes;
      mergedantinodes = foldl' (a: b: a ++ b) [ ] (attrValues antinodes);
      # we need to remove duplicates
      finalantinoes = foldl' (
        acc: antinode: if any (n: n == antinode) acc then acc else acc ++ singleton antinode
      ) [ ] mergedantinodes;
    in
    finalantinoes |> length;
in
{
  part1 = part1 raw;
  part2 = part2 raw;
}
