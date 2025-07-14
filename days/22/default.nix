let
  inherit (builtins)
    bitXor
    div
    mul
    genList
    foldl'
    split
    filter
    readFile
    isString
    fromJSON
    ;

  fileContents =
    file: readFile file |> split "\n" |> filter (c: isString c && c != "") |> map fromJSON;

  sum = xs: foldl' (acc: x: acc + x) 0 xs;

  # 2000 iterations of the generator :p
  itr = genList (x: x) 2000;

  mod =
    a: b:
    let
      q = div a b;
      p = mul q b;
    in
    a - p;

  step1 = x: x * 64 |> bitXor x |> (x: mod x 16777216);
  step2 = x: div x 32 |> bitXor x |> (x: mod x 16777216);
  step3 = x: x * 2048 |> bitXor x |> (x: mod x 16777216);
  genNext = x: x |> step1 |> step2 |> step3;

  construct = x: foldl' (acc: v: genNext acc) x itr;

  p1 = map construct (fileContents ./input);
in
sum p1
