/*
  Stockfish, a UCI chess playing engine derived from Glaurung 2.1
  Copyright (C) 2004-2020 The Stockfish developers (see AUTHORS file)

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//Definition of input features HalfKP of NNUE evaluation function

#include "half_kp.h"
#include "index_list.h"

namespace Eval::NNUE::Features {

  // Orient a square according to perspective (rotates by 180 for black)
  inline Square orient(Color perspective, Square s) {
    return Square(int(s) ^ (bool(perspective) * 63));
  }

  // Find the index of the feature quantity from the king position and PieceSquare
  template <Side AssociatedKing>
  inline IndexType HalfKP<AssociatedKing>::MakeIndex(
      Color perspective, Square s, Piece pc, Square ksq) {

#if defined(ANTI) || defined(TWOKINGS)
    if (ksq == SQ_NONE)
      return IndexType(orient(perspective, s) + kpp_board_index[pc][perspective]);
#endif
    return IndexType(orient(perspective, s) + kpp_board_index[pc][perspective] + PS_END * ksq);
  }

  // Get a list of indices for active features
  template <Side AssociatedKing>
  void HalfKP<AssociatedKing>::AppendActiveIndices(
      const Position& pos, Color perspective, IndexList* active) {

    Square ksq;
    Bitboard bb;
    switch (pos.variant()) {
#ifdef ANTI
    case ANTI_VARIANT:
      ksq = SQ_NONE;
      bb = pos.pieces();
    break;
#endif
#ifdef HORDE
    case HORDE_VARIANT:
      if (pos.is_horde_color(perspective))
        ksq = SQ_NONE;
      // Safeguard against segmentation fault
      bb = (pos.count<PAWN>(WHITE) <= 8 && pos.count<PAWN>(BLACK) <= 8) ? pos.pieces() & ~pos.pieces(KING) : 0;
    break;
#endif
    default:
      ksq = orient(perspective, pos.square<KING>(perspective));
      bb = pos.pieces() & ~pos.pieces(KING);
    }
    while (bb) {
      Square s = pop_lsb(&bb);
      active->push_back(MakeIndex(perspective, s, pos.piece_on(s), ksq));
    }
  }

  // Get a list of indices for recently changed features
  template <Side AssociatedKing>
  void HalfKP<AssociatedKing>::AppendChangedIndices(
      const Position& pos, const DirtyPiece& dp, Color perspective,
      IndexList* removed, IndexList* added) {

    Square ksq;
    switch (pos.variant()) {
#ifdef ANTI
    case ANTI_VARIANT:
      ksq = SQ_NONE;
    break;
#endif
#ifdef CRAZYHOUSE
    case CRAZYHOUSE_VARIANT:
      // Safeguard against segmentation fault
      return;
#endif
#ifdef HORDE
    case HORDE_VARIANT:
      // Safeguard against segmentation fault
      return;
#endif
#ifdef TWOKINGS
    case TWOKINGS_VARIANT:
      ksq = SQ_NONE;
    break;
#endif
    default:
      ksq = orient(perspective, pos.square<KING>(perspective));
    }
    for (int i = 0; i < dp.dirty_num; ++i) {
      Piece pc = dp.piece[i];
      switch (pos.variant()) {
#ifdef ANTI
      case ANTI_VARIANT:
      break;
#endif
#ifdef TWOKINGS
      case TWOKINGS_VARIANT:
      break;
#endif
      default:
      if (type_of(pc) == KING) continue;
      }
      if (dp.from[i] != SQ_NONE)
        removed->push_back(MakeIndex(perspective, dp.from[i], pc, ksq));
      if (dp.to[i] != SQ_NONE)
        added->push_back(MakeIndex(perspective, dp.to[i], pc, ksq));
    }
  }

  template class HalfKP<Side::kFriend>;

}  // namespace Eval::NNUE::Features