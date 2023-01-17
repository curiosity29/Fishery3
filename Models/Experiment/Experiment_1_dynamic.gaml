/* experiment 1:
 * dynamic model for testing - only changing the first section mentioned below
 * 
 */

model Experiment1dynamic

// CHANGE THIS ONLY - BEGIN
//

global torus: true
{
	// please manually change to "global torus: true" with sphere_map = true, same with false
	bool sphere_map <- true;
	
	bool random_birth_location <- true;
	
	float fish_speed <- 1.0;
	int fish_move_rate <- 5;
	
	string description <- "test experiment";
	string today <- "17012023";
	
	// number of repeat with same parameter - still bug with value # 10
	int repeat_number <- 10;
	//	local capacity - workaround because still bug
	int index_1 <- 0;
	int index_2 <- 0;
	float fish_local_cap <- index_1 * 5.5 + index_2 * 0.5 + 1;
//
// CHANGE THIS ONLY - END
	
	// date related
	string simulation_index <- string(10) + string(today) ;

	int index_repeat <- 0;
	
// system
	int rep <- 0;
	float pi <- 3.141592;
	int cycle_max <- 1000;
	int cycle_min <- cycle_max/2;
	float map_size <- 100.0;

	int fish_cap <- 1000;

	int fish_number <- 100;
	//growth rate - work fine if < 1
	float fish_reproduce_rate <- 0.1;				
	float fish_local_density_radius <- 10.0; 
	
	int nb_fish -> {length(fish)};
	init
	{
		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});

	}
	string fileName <- "../includes/results/Capacity/" + "fish_average_" +simulation_index+ ".csv";
	reflex when: cycle = cycle_max
	{
		save [fish_local_cap, fish_average, sphere_map, random_birth_location, fish_speed, fish_move_rate] 
		to: fileName type: "csv" rewrite: false;
	}
	float fish_average <- 0.0;
	int cycle_passed <- 0;
	
	//update current average (from cycle_min to now)
	reflex update when: cycle > cycle_min
	{
		cycle_passed <- cycle_passed + 1 ;
		fish_average <- (fish_average*(cycle_passed-1) + nb_fish)/ cycle_passed;
	}
	
	reflex fish_die
	{
		ask fish
		{
			if self.dead = true {do die;}
		}
	}
	
}

species fish skills: [moving] //parallel: true
{
	float local_density <- 1.0;
	float adjust_factor <- 1.0;
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
		{do wander;}
	}
	
	float area <- pi*fish_local_density_radius^2 ;
	reflex reproduce
	{
		if !sphere_map
		{
			// fish location
			float x <- self.location.x;
			float y <- self.location.y;
			float dx <- 0.0; float dy <- 0.0;
			float R <- fish_local_density_radius;
			
				
			// edge cases near border
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
	
			}
		
			adjust_factor <- area / pi / R^2;
		}
		
		local_density <- (1 + length(fish at_distance fish_local_density_radius)) / adjust_factor;
		float reproduce_prob <- fish_reproduce_rate * (1 - local_density/ fish_local_cap);
		if reproduce_prob > 0
		{
			if flip(reproduce_prob)	
			{
				if random_birth_location{ create fish; }
				else { create fish with: (location: self.location);}
			}
		}
		else if flip(-reproduce_prob)
		{
			dead <- true;
		}
	}
	
}


experiment "agent to equation" type: batch keep_seed: false until: cycle > cycle_max parallel: true
{
	init
	{
		save []
		to: fileName type: "csv" rewrite: false;
	}
	parameter "density index 1" var: index_1 min: 1 max: 10 step: 1;
	parameter "density index 2" var: index_2 min: 1 max: 10 step: 1;
	parameter "repeat" var: index_repeat min: 1 max: repeat_number step: 1;
//	parameter "sphere map" var: sphere_map among: [true, false];
//	parameter "random birth location" var: random_birth_location among: [true, false];
//	parameter "fish speed" var: fish_speed among: [1.0, 2.0, 5.0, 10.0, 20.0];
//	parameter "fish move rate" var: fish_move_rate among: [1, 2, 5, 10, 20];
	
	abort
	{
//		save to: "../includes/results/Capacity/" + "parameter" +simulation_index+ ".txt" rewrite: true;
		save description to: "../includes/results/Capacity/" + "description" +simulation_index+ ".txt" rewrite: true;
	}
}
