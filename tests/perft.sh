#!/bin/bash
# verify perft numbers (positions from www.chessprogramming.org/Perft_Results)

error()
{
  echo "perft testing failed on line $1"
  exit 1
}
trap 'error ${LINENO}' ERR

echo "perft testing started"

cat << EOF > perft.exp
   set timeout 10
   lassign \$argv var pos depth result chess960
   if {\$chess960 eq ""} {set chess960 false}
   spawn ./stockfish
   send "setoption name UCI_Chess960 value \$chess960\\n"
   send "setoption name UCI_Variant value \$var\\n"
   send "position \$pos\\ngo perft \$depth\\n"
   expect "Nodes searched? \$result" {} timeout {exit 1}
   send "quit\\n"
   expect eof
EOF

# chess
if [[ $1 == "" || $1 == "chess" ]]; then
  expect perft.exp chess startpos 5 4865609 > /dev/null
  expect perft.exp chess "fen r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -" 5 193690690 > /dev/null
  expect perft.exp chess "fen 8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - -" 6 11030083 > /dev/null
  expect perft.exp chess "fen r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1" 5 15833292 > /dev/null
  expect perft.exp chess "fen rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8" 5 89941194 > /dev/null
  expect perft.exp chess "fen r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10" 5 164075551 > /dev/null
fi

# variants
if [[ $1 == "" || $1 == "variant" ]]; then
  expect perft.exp 3check startpos 5 4865609 > /dev/null
  expect perft.exp antichess startpos 5 2732672 > /dev/null
  expect perft.exp atomic startpos 5 4864979 > /dev/null
  expect perft.exp crazyhouse startpos 5 4888832 > /dev/null
  expect perft.exp horde startpos 6 5396554 > /dev/null
  expect perft.exp kingofthehill startpos 5 4865609 > /dev/null
  expect perft.exp racingkings startpos 5 9472927 > /dev/null
  # additional tests of Fairy-SF (https://github.com/ianfab/Fairy-Stockfish/blob/master/tests/perft.sh)
  expect perft.exp racingkings startpos 4 296242 > /dev/null
  expect perft.exp racingkings "fen 6r1/2K5/5k2/8/3R4/8/8/8 w - - 0 1" 4 86041 > /dev/null
  expect perft.exp racingkings "fen 6R1/2k5/5K2/8/3r4/8/8/8 b - - 0 1" 4 86009 > /dev/null
  expect perft.exp racingkings "fen 4brn1/2K2k2/8/8/8/8/8/8 w - - 0 1" 6 265932 > /dev/null
  expect perft.exp kingofthehill "fen rnb2b1r/ppp2ppp/3k4/8/1PKp1pn1/3Pq3/PBP1P2P/RN1Q1B1R w - - 4 12" 3 19003 > /dev/null
  expect perft.exp 3check "fen 7r/1p4p1/pk3p2/RN6/8/P5Pp/3p1P1P/4R1K1 w - - 1+3 1 39" 3 12407 > /dev/null
  expect perft.exp 3check "fen 7r/1p4p1/pk3p2/RN6/8/P5Pp/3p1P1P/4R1K1 w - - 1 39 +2+0" 3 12407 > /dev/null
  expect perft.exp atomic startpos 4 197326 > /dev/null
  expect perft.exp atomic "fen rn2kb1r/1pp1p2p/p2q1pp1/3P4/2P3b1/4PN2/PP3PPP/R2QKB1R b KQkq - 0 1" 4 1434825 > /dev/null
  expect perft.exp atomic "fen rn1qkb1r/p5pp/2p5/3p4/N3P3/5P2/PPP4P/R1BQK3 w Qkq - 0 1" 4 714499 > /dev/null
  expect perft.exp atomic "fen r4b1r/2kb1N2/p2Bpnp1/8/2Pp3p/1P1PPP2/P5PP/R3K2R b KQ - 0 1" 2 148 > /dev/null
  expect perft.exp antichess startpos 4 153299 > /dev/null
  expect perft.exp giveaway startpos 4 153299 > /dev/null
  expect perft.exp giveaway "fen 8/1p6/8/8/8/8/P7/8 w - - 0 1" 4 3 > /dev/null
  expect perft.exp giveaway "fen 8/2p5/8/8/8/8/P7/8 w - - 0 1" 12 2557 > /dev/null
  expect perft.exp horde startpos 4 23310 > /dev/null
  expect perft.exp horde "fen 4k3/pp4q1/3P2p1/8/P3PP2/PPP2r2/PPP5/PPPP4 b - - 0 1" 4 56539 > /dev/null
  expect perft.exp horde "fen k7/5p2/4p2P/3p2P1/2p2P2/1p2P2P/p2P2P1/2P2P2 w - - 0 1" 4 33781 > /dev/null
  expect perft.exp horde "fen 4k3/7r/8/P7/2p1n2P/3p2P1/1P3P2/PPP1PPP1 w - - 0 1" 4 128809 > /dev/null
  expect perft.exp horde "fen rnbqkbnr/6p1/2p1Pp1P/P1PPPP2/Pp4PP/1p2PPPP/1P2PPPP/PP1nPPPP b kq a3 0 18" 4 197287 > /dev/null
  # pockets
  expect perft.exp crazyhouse startpos 4 197281 > /dev/null
  expect perft.exp crazyhouse "fen 2k5/8/8/8/8/8/8/4K3[QRBNPqrbnp] w - - 0 1" 2 75353 > /dev/null
  expect perft.exp crazyhouse "fen 2k5/8/8/8/8/8/8/4K3[Qn] w - - 0 1" 3 88634 > /dev/null
  expect perft.exp crazyhouse "fen 2k5/8/8/8/8/8/8/4K3/Qn w - - 0 1" 3 88634 > /dev/null
  expect perft.exp crazyhouse "fen r1bqk2r/pppp1ppp/2n1p3/4P3/1b1Pn3/2NB1N2/PPP2PPP/R1BQK2R[] b KQkq - 0 1" 3 58057 > /dev/null
  # 960 variants
  expect perft.exp atomic "fen 8/8/8/8/8/8/2k5/rR4KR w KQ - 0 1" 4 61401 true > /dev/null
  expect perft.exp atomic "fen r3k1rR/5K2/8/8/8/8/8/8 b kq - 0 1" 4 98729 true > /dev/null
  expect perft.exp atomic "fen Rr2k1rR/3K4/3p4/8/8/8/7P/8 w kq - 0 1" 4 241478 true > /dev/null
  expect perft.exp atomic "fen 1R4kr/4K3/8/8/8/8/8/8 b k - 0 1" 4 17915 true > /dev/null
fi

rm perft.exp

echo "perft testing OK"
