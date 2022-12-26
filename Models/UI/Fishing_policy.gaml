

model Fishingpolicy

global
{
	
	// anual time period
	int period_cycle <- 50;
	
	float seed <- 123.0;
	bool fish_parallel <- false;	// bug if true
	bool have_boat <- true;
	bool have_disaster <- false;
	// post parameter
	float carrying_capacity <- 970.0;
	int start_fishing_cycle <- 1300;
	// workaround increment experiment
	int index_repeat <- 0;
	int index_1 <- 0;
	int index_2 <- 0;
//	float fish_local_cap <- 30.0;	// local K
//	float fish_local_cap <- index_1 * 5.5 + index_2 * 0.5 + 1;
	float fish_local_cap <- 30.0;
	
// system
	int simulation_index <- 231200;
	int rep <- 0;
	float pi <- 3.141592;
	int cycle_max <- 1000;
	int cycle_min <- cycle_max/2;
	float map_size <- 100.0;

	int fish_cap <- 1000;

	int fish_number <- 10;
	float fish_reproduce_rate <- 0.01;				// r
	float fish_local_density_radius <- 10.0; 
						
	float fish_speed <- 1.0;
	int fish_move_rate <- 5;
	list<float> agent_fish_arr;
	
	int height <- 10;
	int width <- 10;
	
	
	//boat 
	float boat_fishing_radius <- 20.0;
	list<point> boat_location <- 
	[
		{25.0, 25.0}, {25.0, 75.0}, {75.0, 25.0}, {75.0, 75.0}	
	];
	int boat_number <- length(boat_location);
	
	
	int nb_fish -> {length(fish)};
	int nb_fish_buffer <- fish_number;
	float fish_delta <- 0.0;
	int period_test_cycle <- 10;
	float fish_delta_test_period <- 0.0;
	float fish_delta_test_period_sum <- 0.0;
	float fish_delta_period <- 0.0;
	float fish_delta_period_sum <- 0.0;
	
	reflex dN
	{
		// dN one cycle
		fish_delta <- nb_fish - nb_fish_buffer;
		nb_fish_buffer <- nb_fish;
		fish_delta_test_period_sum <- fish_delta_test_period_sum + fish_delta;
		fish_delta_period_sum <- fish_delta_period_sum + fish_delta;
		if cycle mod period_test_cycle = 0
		{
			fish_delta_test_period <- fish_delta_test_period_sum / period_test_cycle;
//			write fish_delta_test_period_sum;
			fish_delta_test_period_sum <- 0.0;
		}
		if cycle mod period_cycle = 0
		{
			fish_delta_period <- fish_delta_period_sum / period_cycle;
			fish_delta_period_sum <- 0.0;
		}
		
	}
	init
	{
//		create my_equation;

		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});
		
	}
	
	reflex start_fishing when: cycle = start_fishing_cycle and have_boat
	{
		fishing_effort <- fishing_effort_inital;
		loop loc over: boat_location
		{
			create boat
			with: (location: loc);
		}
	}
	
	float fishing_effort_inital <- fish_reproduce_rate*2;
	float fishing_effort <- 0.0;
	float yield_all_period <- 0.0;
	reflex change_policy when: cycle mod period_cycle = 0 and cycle > start_fishing_cycle
	{
		yield_all_period <- 0.0;
		ask boat
		{
			yield_all_period <- yield_all_period + yield_period;
			yield_period <- 0.0;
		}
		
		float area_ratio <- boat_number * pi *boat_fishing_radius^2/ map_size^2;
		// test with simple estimation insted of using differention equation
		float estimated_population <- yield_all_period / period_cycle / fishing_effort/ area_ratio;
		if estimated_population > carrying_capacity/2 
		{
			if fishing_effort < fish_reproduce_rate *2
			{
				fishing_effort <- fishing_effort * 1.3;				
			}
		}
		else
		{
			fishing_effort <- fishing_effort *0.7;
		}

	}
	
	
	list range_freq_old;
	int avg_step <- 200;

		reflex update
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];
//		error <- error + (nb_fish - my_equation[0].N)^2;
	}
	
	float fish_average <- 0.0;
	int cycle_passed <- 0;
	reflex update when: cycle > cycle_min
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];
		cycle_passed <- cycle_passed + 1 ;
		fish_average <- (fish_average*(cycle_passed-1) + nb_fish)/ cycle_passed;
	}
	
	
	
//	reflex fish_die
//	{
//		ask fish
//		{
////			if dead = true {do die;}
//		}
//	}
	
	
	int disaster_cycle <- 500;

	reflex natural_disaster when: cycle >0 and cycle mod disaster_cycle = 0 and have_disaster
	{
		if flip(0.5)
		{
			ask fish
			{
				if flip(0.5)
				{
	//				dead <- true;
					do die;
				}
			}
		}
	}


}


grid my_cell width: width height: height
{
	list<fish> fishs_in_cell;
}

species boat
{
	float effort <- fishing_effort;
	float yield <- 0.0;
	float yield_period <- 0.0;
	
	
	
	reflex catch_fish
	{
		yield <- 0.0;
		
		list<fish> fish_in_area <- fish at_distance boat_fishing_radius;

			loop f over: fish_in_area 
			{
				if f.dead = false and flip (fishing_effort)
				{
					yield <- yield + 1;
					f.dead <- true;
				}
			}
//		int fish_num <- length(fish_in_area);
//		loop times: fish_num
//		{
//			if flip(fishing_effort)
//			{
//				}
//				ask one_of (fish_in_area where (each.dead = false)) { dead <- true; }
//			}
			
//		}
		yield_period <- yield_period + yield;
		yield <- 0.0;
	}
	aspect base {
		draw circle(boat_fishing_radius) color: color;
	}

}

species fish skills: [moving] parallel: fish_parallel
{
	bool chosen_one <- false;
	float local_density <- 1.0;
	float adjust_factor <- pi * fish_local_density_radius^2;
	rgb color <- #red;
	bool dead <- false;
	init
	{
		speed <- fish_speed;
	}

	aspect base {
		draw circle(0.5) color: color;
	}
	aspect show_density
	{
		draw string(int(local_density)) color:#black size:0.5;
	}
	
	reflex move {
		loop times: fish_move_rate
		{do wander;}
	}
	
	float area <- pi*fish_local_density_radius^2 ;
	reflex reproduce
	{
		float x <- self.location.x;
		float y <- self.location.y;
		float dx <- 0.0; float dy <- 0.0;
		float R <- fish_local_density_radius;
		area <- pi * R^2;
		if x < R or x > map_size - R
		{
			dx <- min(x, map_size - x);
		}

		if y < R or y > map_size - R
		{
			dy <- min(y, map_size - y);
		}

		if dx > 0.0 and dy >0.0
		{
			if R^2 < dx^2 + dy^2
			{
				area <- R^2/2 * (360 - 90 - acos(dx/R) - acos(dy/R))/180 * pi 
				+ dx*sqrt(R^2 - dx^2)/2 + dy*sqrt(R^2 - dy^2)/2 + dx*dy;
			}
			else
			{
				area <- R^2/2 * (360 - acos(dx/R) - acos(dy/R)) /180*pi
				+ dx*sqrt(R^2 - dx^2) + dy*sqrt(R^2 - dy^2);
			}
		}
		else if max(dx, dy) > 0.0
		{
			float d <- max(dx,dy);
			area <- R^2/2 * (360 - 2 * acos(d/R))/180 * pi  + d*sqrt(R^2 - d^2);
//			write(acos(d/R));
		}
		
		adjust_factor <- area / pi / R^2;
		
		local_density <- (1 + length(fish at_distance fish_local_density_radius)) / adjust_factor;
		float reproduce_prob <- fish_reproduce_rate * (1 - local_density/ fish_local_cap);
		if reproduce_prob > 0
		{
			if flip(reproduce_prob)	
			{
				create fish with: (location: self.location);
			}
		}
		else if flip(-reproduce_prob)
		{
			dead <- true;
		}
	}
	
}

experiment "main UI" type: gui
{
	reflex fish_die
	{
		ask fish //parallel: false
		{
			if dead = true {do die;}
		}
	}
	
	string name1 <- "fish population changes "  + period_test_cycle + " cycle";
	output
	{
		
		
		display map
		{
			species boat aspect: base;
			species fish aspect: base;
//			species fish aspect: show_density;
		}
		display "fish population"
		{
			chart "fish_population" type: series
			{
				data "Number of fish" value: nb_fish color: #red;
			}
		}
		display "fishing effort"
		{
			chart "fishing effort" type: series
			{
				data "fishing effort" value: fishing_effort color: #red;
			}
		}
		display name1 refresh: every(period_test_cycle#cycles)
		{
			chart name1 type: series 
			{
				data name1 value: fish_delta_test_period color: #red;
			}
		}
		display "fish population anual changes " refresh: every(period_cycle#cycles)
		{
			chart "fish population anual changes" type: series  
			{
				data "fish population anual changes" value: fish_delta_period color: #red;
			}
		}
			display "fish delta"
		{
			chart "fish delta" type: series  
			{
				data "fish delta" value: fish_delta color: #red;
			}
		}
	}
	
}



//experiment "agent to equation" type: batch keep_seed: false until: cycle > cycle_max parallel: true
//{
////	float m <- 23.0;
////	parameter "repeat workaround" var: rep min: 0 max: 5 step: 1;
//	 
////	parameter "rate" var: fish_reproduce_rate min: 0.02 max: 0.12 step: 0.02;
//
//	parameter "density index 1" var: index_1 min: 0 max: 10 step: 1;
//	parameter "density index 2" var: index_2 min: 0 max: 10 step: 1;
//	parameter "repeat" var: index_repeat min: 0 max: 10 step: 1;
////	parameter "local capacity" var: fish_local_cap min: index * 5 max: index * 5 + 5.0 step: 0.5;
////	parameter "fish_local_density_radius" var: fish_local_density_radius min: 1.0 max: 5.5 step: 1.0;
//	reflex save_result
//	{
//		string fileName <- "../includes/results/Capacity/" + "fish_average_" +simulation_index+ ".csv";
////		save agent_fish_arr to: fileName type: "csv";
////		string fileName <- "../includes/results/RandK/" + "NbFish.csv";
//		save [fish_local_cap, fish_average] to: fileName type: "csv" rewrite: false;
//	}
//
//}
	
	



