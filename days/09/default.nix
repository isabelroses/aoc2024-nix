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
  reverseList =
    xs:
    let
      l = length xs;
    in
    genList (n: elemAt xs (l - n - 1)) l;
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

  raw = "2333133121414131402";
  # raw = builtins.readFile ./input;

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

  removeLast =
    count: list:
    let
      len = length list;
      ajust = len - count;
    in
    genList (n: elemAt list n) ajust;

  swapRecurrsive =
    nodes:
    let
      reversedFiles = reverseList (filter (node: node.type == "File") nodes);

      swap =
        foldl'
          (
            acc: node:
            if node.type == "Space" && length reversedFiles >= acc.revFileIdx then
              {
                revFileIdx = acc.revFileIdx + 1;
                out = acc.out ++ [ (elemAt reversedFiles acc.revFileIdx) ];
              }
            else
              {
                inherit (acc) revFileIdx;
                out = acc.out ++ [ node ];
              }
          )
          {
            out = [ ];
            revFileIdx = 0;
          }
          nodes;

      ajust = removeLast swap.revFileIdx swap.out ++ genList (_: { type = "Space"; }) swap.revFileIdx;
    in
    ajust;

  thisIsCooked =
    nodes':
    let
      maxBlocks = 10000;

      splitAndProcess =
        nodes:
        if length nodes <= maxBlocks then
          checksum (swapRecurrsive nodes)
        else
          let
            first = sublist 0 maxBlocks nodes;
            rest = sublist maxBlocks (length nodes - maxBlocks) nodes;
          in
          checksum (swapRecurrsive first) + thisIsCooked rest;
    in
    splitAndProcess nodes';

  partOne =
    input:
    let
      nodes = parseInput input;
      checksums = thisIsCooked nodes;
    in
    checksums;
in
partOne raw
