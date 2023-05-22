package odindama

import "core:fmt"
import "core:mem"

import la "core:math/linalg"
import n "core:math/linalg/hlsl"
import rl "vendor:raylib"
import rand "core:math/rand"
import "core:strings"

TEST_MODE :: false
SHOW_LEAK :: true

MAX_BOARD :: 64
MAX_FRAME :: 60

MAX_NUMBER_PICES :: 24

WIN_HIGHT :: 800
WIN_WITGH :: 600

COLUMNS :: 8
LINES :: 8

RAINBOW_ENABLE :: false

Square :: struct {
  location:    n.float2,
  size_ocuppy: n.float2,
}

Board :: [COLUMNS][LINES]Square

CirclesPieces :: struct {
  point:      [MAX_NUMBER_PICES]n.float2,
  radious:    [MAX_NUMBER_PICES]f32,
  playing:    [MAX_NUMBER_PICES]bool,
  moving:     [MAX_NUMBER_PICES]bool,
  mouse_over: [MAX_NUMBER_PICES]bool,
  dama:       [MAX_NUMBER_PICES]bool,
}


dama :: proc() {

  windown_dim :: n.int2{WIN_HIGHT, WIN_WITGH}

  rl.InitWindow(windown_dim.x, windown_dim.y, "Dama")
  rl.SetTargetFPS(MAX_FRAME)

  is_running: bool = true

  rl.BeginDrawing()

  circles_pieces: CirclesPieces

  sq_board: Board

  initialize_square_board(&sq_board)

  /// initialize_circles_possition(&circles_pieces, &sq_board)

  for is_running && rl.WindowShouldClose() == false {

    rl.ClearBackground(rl.WHITE)

    render_square_borard(&sq_board)

    // rl.DrawCircle(WIN_HIGHT / 2.0,  WIN_WITGH / 2.0, 10, rl.RED)
    initialize_circles_possition(&circles_pieces, &sq_board)

    // render_circles_on_borard(&circles)

    // rl.DrawText("Hello World!", 100, 100, 20, rl.DARKGRAY)

    // rl.DrawRectangle(i32(player2.p.x), i32(player2.p.y), player2.size.x, player2.size.y, rl.BLACK)
    // rl.DrawRectangle(i32(ball.p.x), i32(ball.p.y), 10, 10, rl.BLACK)
    // rl.DrawText(scores, 1, 1, 20, rl.GRAY)

    rl.EndDrawing()
  }

}

render_circles_on_borard :: proc(sqboard: ^CirclesPieces) {

  for i in 0 ..< MAX_NUMBER_PICES {

    fmt.print(i, " ")
  }
  fmt.println("")
}

initialize_circles_possition :: proc(
  circles_pieces: ^CirclesPieces,
  sq_board: ^Board,
) {

  sizex_t: f32 = WIN_HIGHT / 8.0 // * 0.5
  sizey_t: f32 = WIN_WITGH / 8.0
  offset: f32 = 0.05

  line: f32 = 0.0
  column: f32 = 0.0

  when false {

    LINES_LOOP: for i in 0 ..< MAX_NUMBER_PICES {

      line = f32(i) * sizex_t

    }
  }

  flag: bool = true

  LINES_LOOP: for i in 0 ..< LINES {

    COLUMNS_LOOP: for j in 0 ..< COLUMNS {

      if !(i == 3) && !(i == 4) && !flag {
        rl.DrawCircle(
          auto_cast (sq_board[
              i \
            ][
              j \
            ].location.x +
            (sq_board[j][i].size_ocuppy.x / 2)),
          auto_cast (sq_board[
              i \
            ][
              j \
            ].location.y +
            (sq_board[j][i].size_ocuppy.y / 2)),
          30,
          rl.RED,
        )
      }

      flag = !flag
      // sqboard[i][j] = {n.float2{line, column}, n.float2{sizex_t, sizey_t}}
    }

    flag = !flag
  }
}

initialize_square_board :: proc(sqboard: ^Board) {

  sizex_t: f32 = WIN_HIGHT / 8.0 // * 0.5
  sizey_t: f32 = WIN_WITGH / 8.0
  offset: f32 = 0.05

  line: f32 = 1.0
  column: f32 = 1.0

  COLUMNS_LOOP: for i in 0 ..< LINES {

    line = f32(i) * sizex_t // + 10

    LINES_LOOP: for j in 0 ..< COLUMNS {

      column = f32(j) * sizey_t

      sqboard[j][i] = {n.float2{line, column}, n.float2{sizex_t, sizey_t}}
    }
  }
}

render_square_borard :: proc(sqboard: ^Board) {

  // fmt.println ( sqboard )
  // rl.DrawRectangle(i32(sqboard[0][0].location.x), i32(sqboard[0][0].location.y), i32(sqboard[0][0].size_ocuppy.x), i32(sqboard[0][0].size_ocuppy.y), rl.BLACK)

  flag: bool = true

  LINES_LOOP: for i in 0 ..< LINES {
    COLUMNS_LOOP: for j in 0 ..< COLUMNS {

      when RAINBOW_ENABLE {
        rl.DrawRectangle(
          i32(sqboard[i][j].location.x),
          i32(sqboard[i][j].location.y),
          i32(sqboard[i][j].size_ocuppy.x),
          i32(sqboard[i][j].size_ocuppy.y),
          rl.Color{0x10 * u8(i), 0x40 * u8(j), 0x5, 200.0},
        )
      } else {
        if flag {
          // rl.DrawRectangle(i32(sqboard[i][j].location.x), i32(sqboard[i][j].location.y), i32(sqboard[i][j].size_ocuppy.x), i32(sqboard[i][j].size_ocuppy.y), rl.Color{0x10*u8(i), 0x40*u8(j), 0x5, 200.0})
          rl.DrawRectangle(
            i32(sqboard[i][j].location.x),
            i32(sqboard[i][j].location.y),
            i32(sqboard[i][j].size_ocuppy.x),
            i32(sqboard[i][j].size_ocuppy.y),
            rl.BLUE,
          )
        } else {
          rl.DrawRectangle(
            i32(sqboard[i][j].location.x),
            i32(sqboard[i][j].location.y),
            i32(sqboard[i][j].size_ocuppy.x),
            i32(sqboard[i][j].size_ocuppy.y),
            rl.BLACK,
          )
        }
        flag = !flag
      }
    }
    flag = !flag
  }

}


main :: proc() {

  when SHOW_LEAK {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
  }

  when !TEST_MODE {
    dama()
  } else {

    main_old()
  }

  when SHOW_LEAK {
    for _, leak in track.allocation_map {
      fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
    }
    for bad_free in track.bad_free_array {
      fmt.printf(
        "%v allocation %p was freed badly\n",
        bad_free.location,
        bad_free.memory,
      )
    }
  }
  return
}

main_old :: proc() {

  fmt.println("Hello World")
}
