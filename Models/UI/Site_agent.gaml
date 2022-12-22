
/*
 * Description:
 * 
 * rectangular mxn grid correspond to fish sites
 * 
 * fish move randomly in the environment
 * 
 * the population of each sites is the total number of fish inside that site
 * 
 * 
 */



model Equationbased

global {

//	float fish_local_cap <- 30.0;	// local K
	float fish_local_cap <- 200.0;
	
	
	
	int fish_move_rate <- 1;
// system
	int simulation_index <- 201202;
	int rep <- 0;
	float pi <- 3.141592;
	int cycle_max <- 1000;
	int cycle_min <- cycle_max/2;
	float map_size <- 100.0;

	int fish_cap <- 1000;

	int fish_number <- 200;
	float fish_reproduce_rate <- 0.01;				// r
	float fish_local_density_radius <- 10.0; 
	
	float effort <- fish_reproduce_rate * 8;
						
	float fish_speed <- 1.0;
	list<float> agent_fish_arr;
	
	int height <- 6;
	int width <- 6;
	int color_period <- 200;
	
	int nb_fish -> length(fish);
	
	int yield_all <- 0;
	
	list fish_in_sites_cycle;
	list<list> fish_in_sites_all;
	
	list<int> starting_site <- [2, 2];
	init {
		list<list<int>> fishing_sites <- [
			[1,1],
			[1,5],
			[5,1],
			[5,5]
		];
		ask sites where ([each.grid_x, each.grid_y] in fishing_sites)
		{
			fishing <- true;
		}
		
		
		//temporary?
		sites start_site <- (sites where ([each.grid_x, each.grid_y] = starting_site))[0];
		float starting_x1 <- start_site.location.x;
		float starting_x2 <- starting_x1 + map_size/ width;
		float starting_y1 <- start_site.location.y;
		float starting_y2 <- starting_y1 + map_size/ height;
		
		
		create fish number: fish_number 
		with: (location: {rnd(starting_x1, starting_x2), rnd(starting_y1, starting_y2)});
		
	}
	
	
	
	reflex fish_die
	{
		
		ask fish
		{
			if dead = true
			{
				do die;
			}
		}
	}
	
	reflex update
	{
		fish_in_sites_all <+ fish_in_sites_cycle;
		fish_in_sites_cycle <- [];
		
		yield_all <- 0;
		ask sites
		{
			yield_all <- yield_all + yield;
		}
	}
	
}

species fish skills: [moving] //parallel: true
{

	rgb color <- #green;
	bool dead <- false;
	init
	{
		speed <- fish_speed;
	}

	aspect base {
		draw circle(0.5) color: color;
	}
	
	
	
	reflex move {
		loop times: fish_move_rate
		{do wander speed: fish_speed;}
	}
	
	
	
}

grid sites width: width height: height neighbors: 8
{ 	
	int yield <- 0;
	float growth_rate;
	bool fishing <- false;
	float N <- 0.0;
	float K <- fish_local_cap;
	float Y;
	float x1 <- location.x - map_size/ width/2;
	float x2 <- x1 + map_size/ width;
	float y1 <- location.y - map_size/ height/2;
	float y2 <- y1 + map_size/ height;
	
	reflex check_density
	{
		N <- length(fish inside self);
		
		growth_rate <- fish_reproduce_rate * N *( 1 - N/ fish_local_cap);
		if growth_rate < 0
		{
			loop times: int(growth_rate)
			{
				ask one_of(fish inside self where (each.dead = false)) { dead <- true; }
			}
			if flip(int(growth_rate) - growth_rate)
			{
				ask one_of(fish inside self) { dead <- true; }
			}
		}
		if growth_rate > 0
		{
			// create fish inside
			
			//temporary
			create fish number: int(growth_rate)
			with: (location: {rnd(x1, x2), rnd(y1, y2)});
			
			
			if flip(growth_rate - int(growth_rate))
			{
				// create 1 inside
				
				//temporary
				create fish
				with: (location: {rnd(x1, x2), rnd(y1, y2)});
			
			}
		}
		
		fish_in_sites_cycle <+ N;
	}
	
	
	// bad optimization below
	reflex fishing
	{
		if N>0 and fishing = true
		{
			yield <- int(effort * N);

			if flip(effort*N - yield)
			{
				yield <- yield + 1;
			}
			loop times: yield
			{
				ask one_of(fish where (each.dead = false)){dead <- true;}
			}
		}
		
	}
	
	float color_accumulating <- 0.0;
	float color_accumulated <- 0.0;
	float color_value <- N/K update: N/K;
	rgb color <- hsb(color_value, 1.0, 1.0) ;
//	rgb color <- rgb(color_value, 255 - color_value, 255-color_value) update: rgb(color_value, 255 - color_value, 255-color_value);
	
	reflex color_accumulate
	{
		color_accumulating <- color_accumulating + color_value;
	}
	
	reflex color_change when: cycle mod color_period = 0
	{
		color_accumulated <- color_accumulating/color_period;
		color <- hsb(color_accumulated, 1.0, 1.0);
		color_accumulating <- 0.0;
	}
}


experiment mysimulation type: gui {
	output
	{
		display map
		{
			grid sites border: #black;
			species fish aspect: base;
		}
		
		display Population_information {
			chart "Species evolution" type: series size: {1,0.5} position: {0, 0} {
				data "Number of fish" value: nb_fish color: #blue;
			}
		}
		
		display 3d type: opengl {
	        // Display the grid with elevation
	        grid sites elevation: color_accumulated * 500 triangulation: true border: #black;
	    }
	    
			display Yield_all {
				chart "Yield of all sites" type: series size: {1,0.5} position: {0, 0.5} {
					data "Number of fish catched" value: yield_all color: #red;
				}
		}
	
	}

}



