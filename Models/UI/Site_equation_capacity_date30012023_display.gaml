

/*
 * Description:
 * 
 * rectangular mxn grid correspond to fish sites
 * 
 * fish move between neighboring sites with a fixed rate ( no fish agent )
 * 
 * fish population each sites governed by the logistic equation
 */





model Equationbased

global {

//	float fish_local_cap <- 30.0;	// local K
	float fish_local_cap <- 5.0;
	float fish_local_density_radius <- 5.0; 
	
	
	float move_rate <- 0.1;
	
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
						
	float fish_speed <- 1.0;
	int fish_move_rate <- 5;
	list<float> agent_fish_arr;
	
	int height <- 10;
	int width <- 10;
	
	float nb_fish;
	
	list<float> fish_in_sites_cycle;
	list<list> fish_in_sites_all;
	
	int color_period <- 10;
	
//	list<int> starting_site <- [int(width/2), int(height/2)];
	list<int> starting_site <- [5, 5];
	
	init 
	{
	int width4 <- int(width/4);
	int height4 <- int(height/4);



		ask sites where ([each.grid_x, each.grid_y] = starting_site)
		{
			self.N <- fish_number;
		}
	}
	
	
	
	reflex update
	{
//		fish_in_sites_all <+ fish_in_sites_cycle;
		
		
		nb_fish <- sum(fish_in_sites_cycle);
		fish_in_sites_cycle <- [];

	}
}


grid sites width: width height: height parallel: true neighbors: 8
{ 	
	
	
	float E <- 0.0;
	float K <- fish_local_cap;
	float r <- fish_reproduce_rate;
	float h <- 0.01;
//	float E1 <- 5.0 * h;
	
	float N <- 0.0;
	float t;
	float Y;
	
		equation EQ {			
		diff(N, t) = r * N * (1 - N/K) - E * N;
	}

	reflex solving {
		solve EQ method: #rk4 step_size: 0.01;
		
//		Y <- E * K  * (1 - E / r);
		Y <- E * N;
		fish_in_sites_cycle <+ N;
//		write N;
//		write " ";
//		write fish_in_sites_cycle;
//		write " ";
	}
	
	reflex moving
	{
		float move_out <- move_rate * N;
		N <- N-move_out;
		loop nb over: self.neighbors
		{
			nb.N <- nb.N + move_out/ length(self.neighbors);
		}
	}
	
	float color_value <- N/K update: N/K;
	rgb color <- hsb(color_value, 1.0, 1.0);
//	rgb color <- rgb(color_value, 255 - color_value, 255-color_value) update: rgb(color_value, 255 - color_value, 255-color_value);

	float color_accumulating <- 0.0;
	float color_accumulated <- 0.0;

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
//		display map
//		{
//			grid sites border: #black;
//		}

	    display 3d type: opengl {
	        // Display the grid with elevation
	        grid sites elevation: color_accumulated * 100 triangulation: true border: #black;
	    }
		display Population_information {
			chart "Species evolution" type: series size: {1,0.5} position: {0, 0} {
				data "Number of fish" value: nb_fish color: #blue;
			}
		}
	}
}



