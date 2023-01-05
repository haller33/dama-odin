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

WIN_HIGHT :: 800
WIN_WITGH :: 600

COLUMNS :: 8
LINES :: 8

Square :: struct {
    d : n.float2,
    s : n.float2,
}

Board :: [LINES][COLUMNS]Square

dama :: proc () {
    
    windown_dim :: n.int2{WIN_HIGHT, WIN_WITGH}
    
    rl.InitWindow(windown_dim.x, windown_dim.y, "Dama")
    rl.SetTargetFPS(MAX_FRAME)

    is_running : bool = true
    
    rl.BeginDrawing()

    sqboard : Board

    initialize_square_board ( &sqboard )
    
    for is_running && rl.WindowShouldClose() == false {

	
	rl.ClearBackground(rl.WHITE)
	
	rl.DrawText("Hello World!", 100, 100, 20, rl.DARKGRAY)

	render_square ( &sqboard )

	// rl.DrawRectangle(i32(player2.p.x), i32(player2.p.y), player2.size.x, player2.size.y, rl.BLACK)
	// rl.DrawRectangle(i32(ball.p.x), i32(ball.p.y), 10, 10, rl.BLACK)
	// rl.DrawText(scores, 1, 1, 20, rl.GRAY)
	
	rl.EndDrawing()
    }
}

initialize_square_board :: proc (sqboard : ^Board) {

    sizex_t : f32 = WIN_HIGHT / 8.0 // * 0.5
    sizey_t : f32 = WIN_WITGH / 8.0
    offset : f32 = 0.05

    line   : f32 = 1.0
    column : f32 = 1.0
    
    LINES_LOOP: for i in 0..<LINES {

	line = f32(i)*sizex_t// + 10
	
	COLUMNS_LOOP: for j in 0..<COLUMNS {

	    column = f32(j)*sizey_t
	    
	    sqboard[i][j] = {
		n.float2 { line, column },
		n.float2 { sizex_t, sizey_t },
	    }
	}
    }
}

render_square :: proc (sqboard : ^Board) {

    // fmt.println ( sqboard )
    // rl.DrawRectangle(i32(sqboard[0][0].d.x), i32(sqboard[0][0].d.y), i32(sqboard[0][0].s.x), i32(sqboard[0][0].s.y), rl.BLACK)

    flag : bool = true
    
    LINES_LOOP: for i in 0..<LINES {
	COLUMNS_LOOP: for j in 0..<COLUMNS {

	    
    
	    rl.DrawCircle ( i32(100*j), i32(10*i), 25, rl.RED )
	    
	    when false {
		rl.DrawRectangle(i32(sqboard[i][j].d.x), i32(sqboard[i][j].d.y), i32(sqboard[i][j].s.x), i32(sqboard[i][j].s.y), rl.Color{0x10*u8(i), 0x40*u8(j), 0x5, 200.0})
	    } else {
		if flag {
		    // rl.DrawRectangle(i32(sqboard[i][j].d.x), i32(sqboard[i][j].d.y), i32(sqboard[i][j].s.x), i32(sqboard[i][j].s.y), rl.Color{0x10*u8(i), 0x40*u8(j), 0x5, 200.0})
		    rl.DrawRectangle(i32(sqboard[i][j].d.x), i32(sqboard[i][j].d.y), i32(sqboard[i][j].s.x), i32(sqboard[i][j].s.y), rl.BLUE )
		} else {
		    rl.DrawRectangle(i32(sqboard[i][j].d.x), i32(sqboard[i][j].d.y), i32(sqboard[i][j].s.x), i32(sqboard[i][j].s.y), rl.BLACK)
		}
		flag = !flag
	    }
	}
	flag = !flag
    }

}


main :: proc () {

    when SHOW_LEAK {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)
    }
    
    when !TEST_MODE {
	dama ( )
    } else {

	main_old ()
    }
    
    when SHOW_LEAK {
	for _, leak in track.allocation_map {
	    fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
	    fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
    }
    return
}

main_old :: proc () {

    fmt.println ( "Hello World" )
}
