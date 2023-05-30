package odindama

import "core:fmt"
import "core:mem"

import la "core:math/linalg"
import n "core:math/linalg/hlsl"
import rl "vendor:raylib"
import math "core:math"
import rand "core:math/rand"
import "core:strings"

TEST_MODE :: false
SHOW_LEAK :: false

MAX_SIDE :: 8
MAX_BOARD :: (MAX_SIDE * MAX_SIDE)
MAX_FRAME :: 60
MAX_SQUARES_ONE_COLOR :: (MAX_BOARD / 2)


COLUMNS :: MAX_SIDE
LINES :: MAX_SIDE

MAX_NUMBER_PICES :: (MAX_BOARD / 2) - 8

TRUE_DEBUG :: true
NOT_DISPLAY_NUMBERS_WHEN_NOT_PLAYING :: true
NOT_GO_DEEP_ON_DETECTING_MOUSE_OVER :: true
NUMBERS_ON_CIRCLES :: false || TRUE_DEBUG
DEBUG_INTERFACE :: false || TRUE_DEBUG
DEBUG_MOVING_PIECES :: false || TRUE_DEBUG
DEBUG_DETECT_OVER :: DEBUG_INTERFACE || DEBUG_MOVING_PIECES
COLOR_NUMBERS_ON_CIRCLES :: rl.GRAY
COLOR_DEBUG_LINES :: rl.GREEN
COLOR_DEBUG_LINES_GRID :: rl.YELLOW

PLAYER_ONE :: true
PLAYER_TWO :: false

WIN_HIGHT :: 800
WIN_WITGH :: 600


RADIOUS_CIRCLE_MAX :: 30

RAINBOW_ENABLE :: false

Square :: struct {
  location:    n.float2,
  size_ocuppy: n.float2,
}


Board :: [COLUMNS][LINES]Square

Square_possition :: struct {
  possition: [MAX_SQUARES_ONE_COLOR]n.float2,
}

CirclesPieces :: struct {
  point:                [MAX_NUMBER_PICES]n.float2,
  radious:              [MAX_NUMBER_PICES]f32,
  color:                [MAX_NUMBER_PICES]rl.Color,
  playing_piece:        [MAX_NUMBER_PICES]bool,
  moving:               [MAX_NUMBER_PICES]bool,
  mouse_over:           [MAX_NUMBER_PICES]bool,
  dama:                 [MAX_NUMBER_PICES]bool,
  side:                 [MAX_NUMBER_PICES]bool,
  current_player:       bool,
  possition_mouse_over: n.float2,
}


dama :: proc() {

  set_all_to_not_dama :: proc(circle: ^CirclesPieces) {
    for i in 0 ..< MAX_NUMBER_PICES {
      circle^.dama[i] = false
    }
  }

  windown_dim :: n.int2{WIN_HIGHT, WIN_WITGH}

  rl.InitWindow(windown_dim.x, windown_dim.y, "Dama")
  rl.SetTargetFPS(MAX_FRAME)

  is_running: bool = true

  black_squares: Square_possition

  rl.BeginDrawing()

  circles_pieces: CirclesPieces

  set_all_to_not_dama(&circles_pieces)

  sq_board: Board

  initialize_square_board(&sq_board)

  initialize_circles_possition(&circles_pieces, &sq_board, &black_squares)

  circles_pieces.current_player = PLAYER_ONE

  mouse_now: rl.Vector2

  click_now: bool = false

  for is_running && (rl.WindowShouldClose() == false) {

    mouse_now = rl.GetMousePosition()


    rl.ClearBackground(rl.BLUE)

    render_square_borard(&sq_board)

    rl.DrawCircle(WIN_HIGHT / 2.0, WIN_WITGH / 2.0, 1, rl.RED)

    render_circles_on_borard(&circles_pieces)

    if (rl.IsKeyDown(rl.KeyboardKey.R)) {


      initialize_circles_possition(&circles_pieces, &sq_board, &black_squares)
    }

    keyboard_logics(
      &click_now,
      &circles_pieces,
      auto_cast &mouse_now,
      &black_squares,
    )

    // rl.DrawText("Hello World!", 100, 100, 20, rl.DARKGRAY)

    // rl.DrawRectangle(i32(player2.p.x), i32(player2.p.y), player2.size.x, player2.size.y, rl.BLACK)
    // rl.DrawRectangle(i32(ball.p.x), i32(ball.p.y), 10, 10, rl.BLACK)
    // rl.DrawText(scores, 1, 1, 20, rl.GRAY)

    rl.EndDrawing()
  }
}

keyboard_logics :: proc(
  click_now: ^bool,
  circles_pieces: ^CirclesPieces,
  mouse_now: ^rl.MouseButton,
  square: ^Square_possition,
) {

  if !click_now^ {
    detect_mouse_over(circles_pieces, auto_cast mouse_now)
  }
  if rl.IsMouseButtonReleased(rl.MouseButton.LEFT) {
    click_now^ = false


    realine_circle_moved(circles_pieces, square)
    circles_pieces.current_player = !circles_pieces.current_player

    deattach_mouse(circles_pieces)
  }
  when DEBUG_MOVING_PIECES && DEBUG_INTERFACE {
    if (rl.IsMouseButtonPressed(rl.MouseButton.RIGHT)) {
      remove_playng_piece_mouse_over(circles_pieces)
    }
  }

  if !click_now^ {

    click_now^ = rl.IsMouseButtonPressed(rl.MouseButton.LEFT)
    when DEBUG_MOVING_PIECES {
      //realine_circle_moved(circles_pieces, square)
    }
  }

  if click_now^ {

    if is_correct_piece(circles_pieces) {

      move_circle(circles_pieces, auto_cast mouse_now)

    }
    // render_moving_most_of_circles(circles_pieces)
  }
}

remove_playng_piece_mouse_over :: proc(circles: ^CirclesPieces) {

  DEATACH_PIECE: for i in 0 ..< MAX_NUMBER_PICES {
    if circles.mouse_over[i] {
      circles.playing_piece[i] = !circles.playing_piece[i]
    }
  }
}

is_correct_piece :: proc(circles: ^CirclesPieces) -> (ret: bool) {
  ret = false
  CORRECT_CIRCLE: for i in 0 ..< MAX_NUMBER_PICES {
      if circles.mouse_over[i] && circles.playing_piece[i] {
      if circles.current_player == circles.side[i] {
        ret = true
      }
      break CORRECT_CIRCLE
    }
  }
  return
}

move_circle :: proc(circles: ^CirclesPieces, mouse_now: ^rl.Vector2) {

  for i in 0 ..< MAX_NUMBER_PICES {
    if circles.mouse_over[
         i \
       ] &&
       circles.playing_piece[i] &&
       circles.current_player == circles.side[i] {
      circles.point[i].x = mouse_now[0]
      circles.point[i].y = mouse_now[1]
    }
  }
  when DEBUG_MOVING_PIECES {
    fmt.println(circles.current_player)
  }
}

deattach_mouse :: proc(circles: ^CirclesPieces) {

  LOOP: for i in 0 ..< MAX_NUMBER_PICES {
    circles.mouse_over[i] = false
  }
}

detect_mouse_over :: proc(circles: ^CirclesPieces, mouse_now: ^rl.Vector2) {

  aready_over: bool = false
  MOUSE_OVER_LOOP: for i in 0 ..< MAX_NUMBER_PICES {

    // radios need to be small than distance to
    // mouse been over
    //

    if (aready_over) {
      break MOUSE_OVER_LOOP
    }

    when DEBUG_DETECT_OVER {

      rl.DrawLine(
        auto_cast circles.point[i].x,
        auto_cast circles.point[i].y,
        auto_cast mouse_now[0],
        auto_cast mouse_now[1],
        COLOR_DEBUG_LINES,
      )
    }

    if circles.side[i] == circles.current_player && circles.playing_piece[i] {
      distance := math.sqrt(
        math.pow(mouse_now[0] - circles.point[i].x, 2) +
        math.pow(mouse_now[1] - circles.point[i].y, 2),
      )

      if (distance < RADIOUS_CIRCLE_MAX) {
        circles.possition_mouse_over.x = circles.point[i].x
        circles.possition_mouse_over.y = circles.point[i].y

        when NOT_GO_DEEP_ON_DETECTING_MOUSE_OVER {
          aready_over = true
        }
        circles.mouse_over[i] = true
      } else {
        circles.mouse_over[i] = false
      }
    }
  }
  // fmt.println(circles.mouse_over)
}


/// sees to not working...
render_moving_most_of_circles :: proc(circles: ^CirclesPieces) {

  for i in 0 ..< MAX_NUMBER_PICES {

    if circles.playing_piece[i] && circles.moving[i] {
      rl.DrawCircle(
        auto_cast circles.point[i].x,
        auto_cast circles.point[i].y,
        circles.radious[i],
        circles.color[i],
      )
    }
  }
}

render_circles_on_borard :: proc(circles: ^CirclesPieces) {

  for i in 0 ..< MAX_NUMBER_PICES {

    if (circles.playing_piece[i]) {
      rl.DrawCircle(
        auto_cast circles.point[i].x,
        auto_cast circles.point[i].y,
        circles.radious[i],
        circles.color[i],
      )
    }

    when NUMBERS_ON_CIRCLES {

      display_digits: bool = true

      when NOT_DISPLAY_NUMBERS_WHEN_NOT_PLAYING {
        if !circles.playing_piece[i] {
          display_digits = false
        }
      }
      if display_digits {
        scores: cstring = strings.clone_to_cstring(
          fmt.tprintf("%v", i),
          context.temp_allocator,
        )

        rl.DrawText(
          scores,
          auto_cast circles.point[i].x,
          auto_cast circles.point[i].y,
          20,
          COLOR_NUMBERS_ON_CIRCLES,
        )
      }
    }
  }
}

realine_circle_moved :: proc(
  circles: ^CirclesPieces,
  squares: ^Square_possition,
) {

  moused_mouse_idx: byte = 255
  initial_position: n.float2

  MOUSE_OVER_LOOP: for i in 0 ..< MAX_NUMBER_PICES {

    if circles.mouse_over[i] {
      moused_mouse_idx = cast(byte)i
      initial_position.x = circles.point[i].x
      initial_position.y = circles.point[i].y
      break MOUSE_OVER_LOOP
    }
  }


  // assert(moused_mouse_idx < MAX_SQUARES_ONE_COLOR)

  if moused_mouse_idx < MAX_SQUARES_ONE_COLOR &&
     circles.current_player == circles.side[moused_mouse_idx] {
    distance: f32
    min_distance: f32 = MAX_BOARD
    last_min_square: n.float2
    idx_square: byte

    BOARD_COLOR_LOOP: for i in 0 ..< 32 {

      // fmt.println(squares.possition[i], " ")

      distance := math.sqrt(
        math.pow(
          circles.point[moused_mouse_idx].x - squares.possition[i].x,
          2,
        ) +
        math.pow(
          circles.point[moused_mouse_idx].y - squares.possition[i].y,
          2,
        ),
      )

      when DEBUG_INTERFACE {

        rl.DrawCircle(
          auto_cast squares.possition[i].x - 3,
          auto_cast squares.possition[i].y - 2,
          4,
          rl.ORANGE,
        )

        distance_literal: cstring = strings.clone_to_cstring(
          fmt.tprintf("%v", cast(int)distance),
          context.temp_allocator,
        )
        rl.DrawText(
          distance_literal,
          auto_cast squares.possition[i].x,
          auto_cast squares.possition[i].y,
          15,
          rl.BLUE,
        )

        rl.DrawLine(
          auto_cast squares.possition[i].x,
          auto_cast squares.possition[i].y,
          auto_cast circles.point[moused_mouse_idx].x,
          auto_cast circles.point[moused_mouse_idx].y,
          COLOR_DEBUG_LINES_GRID,
        )
      }

      is_same_last_square: bool =
        circles.possition_mouse_over.x == squares.possition[i].y &&
        circles.possition_mouse_over.y == squares.possition[i].y

      // fmt.print(distance, " ")

      if (distance > 0) && (distance <= min_distance) && !is_same_last_square {

        assert(distance > 0)

        idx_square = cast(u8)i
        min_distance = auto_cast distance
        last_min_square.x = squares.possition[i].x
        last_min_square.y = squares.possition[i].y
      }
    }
    // fmt.println("")

    /*
    fmt.println("mousedID: ", moused_mouse_idx)
    fmt.println("initial_position ", initial_position)
    fmt.println("last_min_square ", last_min_square)
    fmt.println("circles.point ", circles.point[moused_mouse_idx])
    fmt.println("idx_square", idx_square)
    fmt.println(MAX_SQUARES_ONE_COLOR) */
    // fmt.println("min_distance", min_distance)


    if circles.playing_piece[moused_mouse_idx] {


      circles.point[moused_mouse_idx].x = last_min_square.x
      circles.point[moused_mouse_idx].y = last_min_square.y
    }

  }
  /*
    distance := math.sqrt(
      math.pow(mouse_now[0] - circles.point[i].x, 2) +
      math.pow(mouse_now[1] - circles.point[i].y, 2),
    ) */
}

initialize_circles_possition :: proc(
  circles_pieces: ^CirclesPieces,
  sq_board: ^Board,
  black_square: ^Square_possition,
) {

  flag: bool = false
  color_flag: bool = true

  current_color: rl.Color
  one_side :: rl.RED
  other_side :: rl.WHITE
  count_pieces_indx: u8 = 0

  relative_index: int = 0
  LINES_LOOP: for i in 0 ..< LINES {

    COLUMNS_LOOP: for j in 0 ..< COLUMNS {

      if flag {
        black_square^.possition[relative_index].x =
          (sq_board[i][j].location.x + (sq_board[j][i].size_ocuppy.x / 2))
        black_square^.possition[relative_index].y =
          (sq_board[i][j].location.y + (sq_board[j][i].size_ocuppy.y / 2))

        when DEBUG_INTERFACE {

          rl.DrawRectangle(
            auto_cast black_square^.possition[relative_index].x - 3,
            auto_cast black_square^.possition[relative_index].y - 2,
            7,
            5,
            rl.ORANGE,
          )
        }

        relative_index += 1
      }

      if !(i == 3) && !(i == 4) && flag {

        circles_pieces.color[count_pieces_indx] = current_color
        circles_pieces.point[count_pieces_indx].x =
          (sq_board[i][j].location.x + (sq_board[j][i].size_ocuppy.x / 2))
        circles_pieces.point[count_pieces_indx].y =
          (sq_board[i][j].location.y + (sq_board[j][i].size_ocuppy.y / 2))

        circles_pieces.radious[count_pieces_indx] = RADIOUS_CIRCLE_MAX
        circles_pieces.playing_piece[count_pieces_indx] = true
        circles_pieces.mouse_over[count_pieces_indx] = false

        if color_flag {
          circles_pieces.side[count_pieces_indx] = PLAYER_ONE
        } else {
          circles_pieces.side[count_pieces_indx] = PLAYER_TWO
        }

        count_pieces_indx += 1
      }
      if (i == 3) || (i == 4) {
        color_flag = false
      }


      if color_flag {
        current_color = one_side
      } else {
        current_color = other_side
      }

      flag = !flag
      // sqboard[i][j] = {n.float2{line, column}, n.float2{sizex_t, sizey_t}}
    }

    flag = !flag
  }
  circles_pieces.current_player = PLAYER_ONE
}

initialize_square_board :: proc(sqboard: ^Board) {

  sizex_t: f32 = WIN_HIGHT / 8.0 // * 0.5
  sizey_t: f32 = WIN_WITGH / 8.0
  offset: f32 = 0.05

  line: f32 = 1.0
  column: f32 = 1.0

  COLUMNS_LOOP: for i in 0 ..< LINES {

    line = f32(i) * sizex_t

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
