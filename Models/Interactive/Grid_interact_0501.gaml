

model Gridinteract

global 
{
	
// Sites
	int site_width <- 8;
	int site_height <- 8;
	
// Action variables
	int create_fish_number <- 10;
	int create_boat_number <- 1;
	int remove_fish_number <- -10;
	int remove_boat_number <- -1;
	string action_type <- "";	// current action type
	list<string> action_type_list <-
	[
	"make fish", "make boat", "no fishing", "erase",
	"reduce fish", "reduce boat", "no fish"
	];
	/*
	 * images used for the buttons
	* make fish
	* ban fishing
	* remove all option on site
	 */

	
// general
	list<file> images <- [
		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/fish.png"),
		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/boat.png"),
		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/NoFishing.png"),
		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/Eraser.png")
	]; 
//	map<string, int> option_image_index;
	map<string,file> option_image_map <- [
		"make fish"			:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/fish.png"),
		"make boat" 		:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/boat.png"),
		"remove fish" 		:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/dead fish.png"),
		"remove boat"		:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/broken ship.png"),
		"no fishing"			:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/NoFishing.png"),
		"no fish"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/no fish.png"),
		"erase"					:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/Eraser.png"),
		"refresh"	 			:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/refresh.png")
//		"erase 2"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/Eraser.png")
						
	];
	
	init
	{	
		
		create manager;
		
	}
	
// Action
	action activate_act {
		site_options selected_but <- first(site_options overlapping (circle(1) at_location #user_location));

		if(selected_but != nil) {
			ask selected_but 
			{

				ask site_options {bord_col<-#black; }
				if (action_type != id_string) {
					action_type<- id_string;
					bord_col<-#red;
				} else { action_type<- ""; }
				
			}
		}
	}
	action site_management {
		sites selected_site <- first(sites overlapping (circle(1.0) at_location #user_location));
		if(selected_site != nil) {



			switch action_type 
			{
				match "make fish" { do change_fish (create_fish_number, selected_site);}
				match "make boat" { do change_boat (create_boat_number, selected_site);}
				match "remove fish" {do change_fish (remove_fish_number, selected_site);}
				match "remove boat" {do change_boat (remove_fish_number, selected_site);}
				
				match "erase" { ask selected_site{site_types <- [];} }	
				match "refresh" { ask manager {do kill_species;}}
				
				default { ask selected_site {site_types <+ action_type;}}
					
			}
		}
		
	}
	action change_fish(float fish_number, sites site)
	{
		int nb_change;
		if fish_number < 0 
		{
			if flip(int(fish_number) - fish_number) {nb_change <- int(fish_number) - 1;} 
			else {nb_change <- int(fish_number);}
			
			list fish_alive <- fish where (each.dead = false);
			loop index from: 0 to: min(-nb_change, length(fish_alive) - 1) step: 1
			{
				write index;
				ask fish_alive[index] {dead <- true;}
			}
		}
		else
		{
			if flip(fish_number  - int(fish_number)) {nb_change <- int(fish_number) + 1;} 
			else {nb_change <- int(fish_number);}
			
			ask site
			{
					create fish number: nb_change with: 
					(location: {rnd(left, left + my_width), rnd(top, top + my_height)});
			}
		}
		return nb_change;
	}
	action change_boat(float boat_number, sites site)
	{
		int nb_change;
		if boat_number < 0 
		{
			if flip(int(boat_number) - boat_number) {nb_change <- -int(boat_number) - 1;} 
			else {nb_change <- -int(boat_number);}
			
			list boat_alive <- boat where (each.dead = false);
			loop index from: 0 to: min(-nb_change, length(boat_alive) - 1) step: 1
			{
				ask boat_alive[index] {dead <- true;}
			}
		}
		else
		{
			if flip(boat_number  - int(boat_number)) {nb_change <- int(boat_number) + 1;} 
			else {nb_change <- int(boat_number);}
			
			ask site
			{
					create boat number: nb_change with: 
					(location: {rnd(left, left + my_width), rnd(top, top + my_height)});
			}
		}
		return nb_change;
	}
	
}




grid sites width: site_width height: site_height neighbors: 4
{
	species first_micro_species { aspect base{} }
	grid site_type_grid width: 2 height: 2
	{
		int index <- int(self);
		aspect base
		{
			if index < length(site_types)
			{
				switch site_type
				{
					match "no fishing" draw image_file(option_image_map["no fishing"]) size: mysize4;
					match "no fish" { draw image_file(image_file(option_image_map["no fish"])) size: mysize4; }
				}
			}
		}
	}
	
//	init
//	{
//		create
//	}
	bool no_fishing update: "no fishing" in site_types;
	
// Interface
	float my_width <- 100.0/ site_width;
	float my_height <- 100.0/ site_height;
	float mysize4 <- min(my_width,  my_height)/3;
	
	// position 1/4
	float top <- self.location.y - my_height/2;
	float left <- self.location.x - my_width/2;
	float right <- left + my_width;
	float bottom <- top + my_height;
	point draw_fix <- {my_width/4, my_height/4};
	
	int fish_agent_inside update: length(fish inside self);
	float fish_equation_inside <- 0.0;
	float fish_inside update: fish_agent_inside + fish_equation_inside;
	
	rgb color <- #white ;
	list<string> site_types <- [];
	
	
	aspect default 
	{
		loop site_type over: site_types
		{
			switch site_type
			{
				match "no fishing" { draw image_file(option_image_map["no fishing"]) size: mysize4 at: {left, top} + draw_fix; }
//				match "no fishing" { draw image_file(images[option_image_index["no fishing"]]); }
			}
		}
//				draw image_file(images[site_type]) size:{shape.width * 0.5,shape.height * 0.5} ;				
	}
	aspect show_fish_inside
	{
		draw string(fish_inside) size: 1 at: {right, bottom} - draw_fix color: #black;
	}
	
	
// Behavior
	reflex boat_move
	{
		ask boat inside self
		{
			do goto target: one_of(myself.neighbors where (each.no_fishing = false));
		}
	}
	
// Skill
	reflex agent_to_equation
	{
		fish_equation_inside <- fish_inside;
		
		ask fish inside self {dead <- true;}
		fish_agent_inside <- 0;
		
	}
	
	reflex equation_to_agent
	{
		ask world{ do change_fish(myself.fish_equation_inside, myself); }
		fish_equation_inside <- 0.0;
		
	}

}


grid site_options width: 4 height: 2 
{

	int id <- int(self);
	string id_string <- option_image_map.keys[id];
	rgb bord_col<-#black;
	aspect normal {
		draw rectangle(shape.width * 0.8,shape.height * 0.8).contour + (shape.height * 0.01) color: bord_col;
		draw  image_file(option_image_map[id_string]) size:{shape.width * 0.5, shape.height * 0.5} ;
	}
	
	
	

}



species fish skills: [moving]
{

// general
	bool dead <- false;
	init
	{
		speed <- 2.0;
	}
	reflex move
	{
		do wander;
	}
	aspect base
	{
		draw circle(0.5) color: #red;
	}
}


species boat skills: [moving]
{
//general 
	bool dead <- false;
	init
	{
		speed <- 5.0;
	}
	
	aspect base
	{
		draw circle(0.5) color: #blue;
	}
	aspect fancy
	{
		draw image_file(option_image_map["make boat"]) size: 3;
	}
}




species manager
{
	
	action kill_species
	{
		ask fish { if dead = true {	 do die;}
	}
		ask boat{ if dead = true {do die;}}
	}
	
	reflex kill_species
	{
		do kill_species;
	}
}







experiment Grid_interact type: gui {
	output {
			layout horizontal([0.0::7285,1::2715]) tabs:true;
		display map {
			grid sites border: #black;
			species sites aspect: default;
			event mouse_down action: site_management;
			

			species first_micro_species aspect: base;
//			grid site_type_grid border: #black;
//			species site_type_grid aspect: base;
//			
			species fish aspect: base;
			species boat aspect: fancy;
			
			species sites aspect: show_fish_inside;
		}
		//display the action buttons
		display action_buton background:#black name:"Tools panel"  	{
			species site_options aspect:normal ;
			event mouse_down action:activate_act;
		}
	}
}
