
/* experiment 1.1:
 * 
 *  don't change this file
 */

model Experiment1dynamic

global torus: true
{
	// please manually change to "global torus: true" with sphere_map = true, same with false
	bool sphere_map <- true;
	
	bool random_birth_location <- true;
	
	float fish_speed <- 1.0;
	int fish_move_rate <- 1;
	
	string description <- "experiment january 17 with torus environment, vary fish movement speed and random birth location = true or false, repeat 10 times with increasing local density from 6 to 60";
	string today <- "17012023";
	string simulation_index <- today + "02" ;
	
	// number of repeat with same parameter - still bug with value # 10
	int repeat_number <- 10;
	//	local capacity - workaround because still bug
	int index_1 <- 0;
	int index_2 <- 0;
	int index_repeat <- 0;
//	float fish_local_cap <- index_1 * 5.5 + index_2 * 0.5 + 1;


	reflex
	{
		ask fish { do reproduce;}
		ask fish { do fish_move;}
		ask fish { if self.dead = true {do die;}}
	}

	
// system
	float pi <- 3.141592;
	int rep <- 0;
	int cycle_max <- 20000;
//	int cycle_min <- cycle_max/2;
	float map_size <- 100.0;

//	int fish_cap <- 1000;

	//growth rate - work fine if < 1
	float fish_reproduce_rate <- 0.01;				
	
	int nb_fish -> {length(fish)};
	
	float fish_local_cap <- 15.0;
	float fish_local_density_radius <- 15.0; 
	
	
	// diff equation
	float K <-  fish_local_cap * 100 ^2/ pi/fish_local_density_radius^2;
	float k <- fish_local_cap;
	float binomialK <- K + 1 - K/k;
	float p <- k/K;
	float var <- 0.0;
	float delta <- 0.0;
	float root1 <- 0.0;
	float root1_average <- 0.0;
	list<float> dens_list;
	float dN_expected <- 0.0;
	float var_average;
	
	int fish_number <- 5;
	float r <- fish_reproduce_rate;
	list<float> dens_range <- [0, 1/4, 2/4, 3/4, 1, 5/4, 6/4, 7/4];
	init
	{
	dens_range <- dens_range collect ((each+1/8) *k);
	
		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});

	}
	string fileName <- "../includes/results/Capacity/" + "fish_average_" +simulation_index+ ".csv";
	reflex save_result when: cycle = cycle_max
	{
		save [fish_local_cap, fish_average, sphere_map, random_birth_location, fish_speed, fish_move_rate] 
		to: fileName type: "csv" rewrite: false;
	}
	
	
	float fish_average <- 0.0;
	int cycle_passed <- 0;
	int cycle_min <- 2000;
	//update current average (from cycle_min to now)
	reflex update when: cycle > cycle_min
	{
		cycle_passed <- cycle_passed + 1 ;
		fish_average <- (fish_average*(cycle_passed-1) + nb_fish)/ cycle_passed;
		root1_average <- (root1_average*(cycle_passed-1) + root1)/ cycle_passed;	
	}
	reflex stop_exp when: cycle > cycle_max
	{
		do pause;
	}
	reflex fish_die
	{
		ask fish
		{
			if self.dead = true {do die;}
		}
	}
	
	float mean <- 0.0;
	float dN_cut <- 0.0;
	float var_binomial <- 0.0;
	float var_moving_average;
	list<float> var_list;

	reflex calculate_var
	{
		ask fish { dens_list <+ 1 + length(fish at_distance fish_local_density_radius); }
		var <- variance(dens_list);
		mean <- mean(dens_list);
		var_list<+ var;
		// moving avg of var
		float sum <- 0.0;
		if cycle > 20
		{
			loop id from: length(var_list)-20 to: length(var_list)-1
			{
				sum <- sum + var_list[id];
			}
			var_moving_average <- sum / 20;
		}
		// end moving avg of var
		var_binomial <- nb_fish*p*(1-p);

		dN_cut <- nb_fish* (mean - (var + mean^2) / k);
		if cycle > cycle_min
		{var_average <- (var_average*(cycle_passed-1) + var)/ cycle_passed;	}
		delta <- 1 - 4 * var/k^2;
		if delta < 0 {root1 <- 0.0;}
		else {root1 <- 1/2 * K * (1 + sqrt(delta));}
		
		dens_list <- [];
	}
	
	float EN <- 0.0;
	reflex calculate_dN
	{
		EN <- nb_fish*p;
		dN_expected <- -r/p/k * (EN^2 - k * EN + var);
	}
	
// chart name
//	string s <- "population with local capacity = "+ fish_local_cap + ", radius = "+ fish_local_density_radius ;
}

species fish skills: [moving] parallel: true
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
	
	
	
	action fish_move {
		// random location
		location <- any_location_in(world.shape);
		// normal movement
//		loop times: fish_move_rate
//		{do wander;}
	}
	
	float area <- pi*fish_local_density_radius^2 ;
	action reproduce
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


experiment "display"
{

	output
	{
//		display map
//		{
//			species fish aspect: base;
//		}
		monitor "average population" value: fish_average;
		monitor "binomial capacity" value: binomialK;
		monitor "average variance" value: var_average;
		monitor "ideal capacity" value: K;
		monitor "average root capacity" value: root1_average;
//		monitor "dN expected" value: dN_expected;

		display population
		{
			chart "population" type: series
			{
				
				data "population" value: nb_fish color: #blue;
				data "binomial capacity" value: binomialK color: #red;
				data "ideal capacity" value: K color: #green;
				data "average population" value: fish_average color: #black;
				data "root capacity" value: root1 color: #purple;
//				data "dN expected" value: dN_expected*K/2 color:#purple; 
//				data "dN relative value" value: dN_cut color: #black;
			}
		}
		display "variance"
		{
//				data "mean" value: mean color: #red;
//				data "Np" value: nb_fish*p color: #blue;
//				data "delta" value: mean - nb_fish*p color: #black;
//				data "1" value: 1 color: #black;

			chart "variance" type: series  
			{
				data "var binomial" value: var_binomial color: #red;
				data "var" value: var color: #blue;
//				data "moving average" value: var_moving_average color: #green;
				data "average variance" value: var_average color: #black;

			}
		}
//		display "local density"
//		{
//
//			chart "local density" type: series  
//			{
//				data "mean density" value: mean color: #red;
//				data "mean binomial" value: nb_fish*p color: #blue;
//			}
//		}
//		display "local density histogram"
//		{
//
//			chart "local density histogram" type: histogram 
//			{
//				data "<" + dens_range[0] value: dens_list count (each <= dens_range[0]) color: #blue;
//				loop index from: 0 to: length(dens_range)-2
//				{
//					data "" + dens_range[index] + "-" + dens_range[index+1] value: dens_list count ((each > dens_range[index]) and (each <= dens_range[index+1])) color: #blue;
//				}
//				data ">" + dens_range[0] value: dens_list count (each > last(dens_range)) color: #blue;
//			}
//		}
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
	parameter "random birth location" var: random_birth_location among: [true, false];
	parameter "fish speed" var: fish_speed among: [1.0, 2.0, 5.0, 10.0, 20.0];
	parameter "fish move rate" var: fish_move_rate among: [1, 2, 5, 10, 20];
	
	abort
	{
//		save to: "../includes/results/Capacity/" + "parameter" +simulation_index+ ".txt" rewrite: true;
		save description to: "../includes/results/Capacity/" + "description" +simulation_index+ ".txt" rewrite: true;
	}
}
