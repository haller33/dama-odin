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

dama :: proc () {
    
    windown_dim :: n.int2{800, 600}
    
    rl.InitWindow(windown_dim.x, windown_dim.y, "Dama")
    rl.SetTargetFPS(60)

    is_running : bool = true
    
    rl.BeginDrawing()
    
    for is_running && rl.WindowShouldClose() == false {

	
	rl.ClearBackground(rl.WHITE)
	
	rl.DrawText("Hello World!", 100, 100, 20, rl.DARKGRAY)

	// rl.DrawRectangle(i32(player1.p.x), i32(player1.p.y), player1.size.x, player1.size.y, rl.BLACK)
	// rl.DrawRectangle(i32(player2.p.x), i32(player2.p.y), player2.size.x, player2.size.y, rl.BLACK)
	// rl.DrawRectangle(i32(ball.p.x), i32(ball.p.y), 10, 10, rl.BLACK)
	// rl.DrawText(scores, 1, 1, 20, rl.GRAY)
	
	rl.EndDrawing()
    }
}
