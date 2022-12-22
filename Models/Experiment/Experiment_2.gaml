/**
* Name: Experiment2
* Based on the internal empty template. 
* Author: doman
* Tags: 
*/


model Experiment2

/* Insert your model definition here */

global
{
// system
int cycle_max <- 1001;
	int cycle_min <- cycle_max/2;
	int simulation_index <- 121201;
	float map_size <- 100.0;
	float pi <- 3.141592;
	int index_1 <- 0;
	int index_2 <- 0;
//	string note_name <- "variance with ";
	// parameter for both models
	int fish_number <- 300;
	int fish_cap <- 1000;
	
//	int fish_reproduce_rate_index <- 10;
//	float fish_reproduce_rate <- fish_reproduce_rate_index * 0.01;				// r
	float fish_reproduce_rate <- 0.03;
	
	//equation parameter	
	float h <- 0.01;	// step size

	// agent parameter
	
	float fish_local_density_radius <- 10.0; 
	float fish_local_cap <- 20.0;						// local K
	float fish_speed <- 1.0;
	int fish_move_rate <- 5;
	list<float> agent_fish_arr;
	float density_square_sum <- 0.0 ;
	float density_sum_square <- 0.0;
	
	
	int height <- 10;
	int width <- 10;
	
	int nb_fish -> {length(fish)};
	list nb_fish_arr <- [0.0];		// 0.0 to remove in python later
	list density_square_sum_arr <- [0.0];
	list density_sum_square_arr <- [0.0];
	
	init
	{
//		create my_equation;

		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});
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
	reflex update_stable when: cycle > cycle_min
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];
		cycle_passed <- cycle_passed + 1 ;
		fish_average <- (fish_average*(cycle_passed-1) + nb_fish)/ cycle_passed;
	}
	
	reflex update
	{
		nb_fish_arr <+ nb_fish;
		density_sum_square <- density_sum_square^2;
		
		density_square_sum_arr <+ density_square_sum;
		density_sum_square_arr <+ density_sum_square;
		density_square_sum <- 0.0;
		density_sum_square <- 0.0;
	}
}


species fish skills: [moving] parallel: true
{
	float local_density <- 1.0;
	float adjust_factor <- pi * fish_local_density_radius^2;
	rgb color <- #green;
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
	
	float area;
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
		
		local_density <- (1+length(fish at_distance fish_local_density_radius)) / adjust_factor;
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
			do die;
		}
	}
	
	reflex stats_update
	{
		density_square_sum <- density_square_sum + local_density^2 ;
		density_sum_square <- density_sum_square + local_density;
	}
}


experiment "agent to equation" type: batch keep_seed: false until: cycle > cycle_max parallel: true
{
	parameter "fish grow rate" var: fish_reproduce_rate min: 0.01 max: 0.11 step: 0.01;
	
	parameter "index of simulation 1" var: index_1 min: 0 max: 10 step: 1;
	parameter "index of simulation 2" var: index_2 min: 0 max: 10 step: 1;
	parameter "fish move rate" var: fish_move_rate min: 2 max: 22 step: 2;
	parameter "fish intial number" var: fish_number min: 2 max: 102 step: 10;
	

	
	
//	parameter "local capacity" var: fish_local_cap min: 36.5 max: 41.5 step: 0.5;
//	parameter "fish reproduce rate %" var: fish_reproduce_rate_index min: 1 max: 11 step: 1;
	reflex save_result
	{
//		int index <- 10* index_1 + index_2;
//		simulation_index <- "712" + index;
		string fileName <- "../includes/results/RandK/" + "rate_to_fish_nb/"
		+ fish_reproduce_rate +
		"/fish_nb_" 	+ simulation_index+ ".csv";
//		save agent_fish_arr to: fileName type: "csv";
//		string fileName <- "../includes/results/RandK/" + "NbFish.csv";
		save [fish_reproduce_rate, fish_move_rate, fish_number, index_1, index_2, 
			nb_fish_arr, density_square_sum_arr, density_sum_square_arr
		] 
		to: fileName type: "csv" rewrite: false header: false;
		
		
//		string header_file_name <- "../includes/results/RandK/" + "rate_to_fish_nb/"
//		+ fish_reproduce_rate +
//		"/Header_" 	+ simulation_index+ ".csv";
//		save [fish_reproduce_rate, fish_move_rate, fish_number]
//		to: header_file_name type: "csv" rewrite: false header: true;
		
}


}
