let
  inherit (builtins)
    map
    fromJSON
    filter
    split
    elemAt
    bitAnd
    genList
    length
    concatLists
    isList
    foldl'
    add
    ;

  imap0 = f: list: genList (n: f n (elemAt list n)) (length list);
  range = first: last: if first > last then [ ] else genList (n: first + n) (last - first);

  # raw = "2333133121414131402";
  raw = builtins.readFile ./input;

  parseInput =
    input:
    let
      digits = split "([0-9])" input |> filter isList |> concatLists |> map fromJSON;

      nodes' = imap0 (
        i: d:
        if bitAnd i 1 == 0 then
          map (_: {
            type = "File";
            id = i / 2;
          }) (range 0 d)
        else
          map (_: { type = "Space"; }) (range 0 d)
      ) digits;

      nodes = concatLists nodes';
    in
    nodes;

  checksum =
    nodes:
    let
      filteredNodes = imap0 (i: node: if node.type == "File" then i * (elemAt nodes i).id else 0) nodes;
    in
    foldl' add 0 filteredNodes;

  makeReadable = nodes: foldl' (acc: node: acc + (toString node.id or ".")) "" nodes;

  swap =
    nodes: l: r:
    map (
      i:
      if i == l then
        elemAt nodes r
      else if i == r then
        elemAt nodes l
      else
        elemAt nodes i
    ) (range 0 (length nodes));

  swapRecurrsive =
    nodes':
    let
      loop =
        {
          nodes,
          l,
          r,
        }:
        if l < r then
          let
            leftNode = elemAt nodes l;
            rightNode = elemAt nodes r;

            nextL = l + 1;
            nextR = r - 1;

            acc =
              if leftNode.type == "Space" && rightNode.type == "File" then
                {
                  nodes = swap nodes l r;
                  l = nextL;
                  r = nextR;
                }
              else if leftNode.type == "Space" && rightNode.type == "Space" then
                {
                  inherit nodes l;
                  r = nextR;
                }
              else
                {
                  inherit nodes r;
                  l = nextL;
                };
          in
          loop acc
        else
          nodes;
    in
    loop {
      nodes = nodes';
      l = 0;
      r = length nodes' - 1;
    };

  partOne =
    input:
    let
      nodes = parseInput input;
      swappedNodes = swapRecurrsive nodes;
    in
    checksum swappedNodes;
in
partOne raw
