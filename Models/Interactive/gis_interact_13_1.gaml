
model gisinteract131

/*
 * site type (on/off): fish/fishing/
 * 
 * fish form: agent/equation
 * 
 * fish local density: radius/site
 * 
 * boat catch: radius/site
 * 
 * 
 */

global 
{
	//file
	file shape_file_boundary <-
	file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/Shape/vnm/vnm_admbnda_adm0_gov_20200103.shp");
	file shape_file_docks <-
	file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/Shape/Shape file vn/Cang.shp");
	
	file shape_file_marine <-
	file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/Shape/eez/eez.shp");
	geometry shape <- envelope(shape_file_boundary) union envelope(shape_file_marine);
	float map_width <- shape.width;
	float map_height <- shape.height;
//	float area <- map_height * map_width;
//	int target_number_of_sites <- 200;
//	int site_width <- 20;
//	int site_height <- 100;
	
// observe
	float yield_all <- 0.0;
	float yield_vn <- 0.0;
	float yield_cn <- 0.0;
	reflex reset
	{
		yield_vn <- 0.0;
		yield_cn <- 0.0;
	}
	
// Sites
	float remove_threshold <- 0.05;
	int vertical_slice <- 50;
	int horizontal_slice <- 50;
// Action variables
	int create_fish_number <- 100;
	int create_boat_number <- 5;
	int remove_fish_number <- - 100;
	int remove_boat_number <- -10;
//	string action_type <- "";	// current action type
	site_options selected_but; // current selected button
//	list<string> action_type_list <-
//	[
//	"make fish", "make boat", "no fishing", "erase",
//	"reduce fish", "reduce boat", "no fish"
//	];
	/*
	 * images used for the buttons
	* make fish
	* ban fishing
	* remove all option on site
	 */

	
// general
//	list<file> images <- [
//		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/fish.png"),
//		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/boat.png"),
//		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/NoFishing.png"),
//		file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/Eraser.png")
//	]; 
////	map<string, int> option_image_index;
	map<string,file> option_image_map <- [
		"make fish"			:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/fish.png"),
		"make boat" 		:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/boat.png"),
		"remove fish" 		:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/dead fish.png"),
		"remove boat"		:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/broken ship.png"),
		
		"no fishing"			:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/NoFishing.png"),
		"no fish"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/no fish.png"),
		"button1"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/button.png"),
		"button2"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/button.png"),
		
		"to equation"		:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/equation1.png"),
		"to agent"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/agent1.png"),
		"button3"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/button.png"),
		"button4"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/button.png"),
		
		"erase"					:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/Eraser.png"),
		"refresh"	 			:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/refresh.png"),
		"button5"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/button.png"),
		"button6"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/button.png")
//		"erase 2"				:: file("C:/Users/doman/My Drive/GAMA/Gama/Fishery/Dependence/IMG/Eraser.png")
						
	];
	
	
// boat
	float fishing_effort <- 0.05;
	

// fish
	float reproduce_rate <- 0.1;
	

	init
	{	

		create docks from: shape_file_docks;
		create boundary from: shape_file_boundary;
		create marine from: shape_file_marine;
		create manager;
		
		ask sites
		{
			neighbors8 <- sites closest_to (self, 8) where ( distance_to(each, self) < 0.01 );
			neighbors9 <- neighbors8 union [self];
			
//			write "sites: " + self;
//			write "neighbors:";
//			loop nb over: neighbors8
//			{
//				write nb;
//				if distance_to(nb.location, self.location) > 0.0
//				{
//					write "distance from " + self + " to" + nb +": " +distance_to(nb, self);							
//				}
//			}
//			ask sites
//			{
////				if distance(self, mys
////				neighbors4 <+				
//			}
		}
//		create fish number: 10000;
	}
	
// Action
	action activate_act {
		write "";
		site_options selected_but_new <- first(site_options overlapping (circle(1) at_location #user_location));

		if(selected_but_new = nil) { return; }
		
		if(selected_but != nil) {ask selected_but {bord_col <- #black; }}
		string action_type <- selected_but_new.id_string;
		bool activated <- true;
		switch action_type
		{
			match "to agent" { ask sites {do equation_to_agent;}}
			match "to equation" { ask sites {do agent_to_equation;}}
			match "refresh" { ask manager {do kill_species;}}
			default {activated <- false;}
		}
		if activated 
		{
		 	ask manager {do kill_species;}
			selected_but <- nil;
			return;
		}
		if( selected_but_new = selected_but) 
		{
			selected_but <- nil;
			return;
		}
		selected_but <- selected_but_new;
		ask selected_but {bord_col <- #red;}
		ask selected_but {		write id_string;	}
	}
	action site_management {
				write "";
		sites selected_site <- first(sites overlapping (circle(1) at_location #user_location));
		write selected_site;
		if(selected_site != nil and selected_but != nil) {

		write "selected site with: " + selected_but.id_string ;
		ask selected_site 	{ do update; }
			switch selected_but.id_string 
			{
				match "button" {}
				
				match "make fish" { do change_fish (create_fish_number, selected_site);}
				match "make boat" { do change_boat (create_boat_number, selected_site);}
				match "remove fish" {do change_fish (remove_fish_number, selected_site); }
				match "remove boat" {do change_boat (remove_boat_number, selected_site);}
			
//				match "button" {}
//				match "button" {}
				
				match "erase" { ask selected_site{site_types <- [];} }	

				
				default { ask selected_site {site_types <+ selected_but.id_string ;}}
					
			}
			ask selected_site 	{ do update; }
			
			ask selected_site {write "site type now: " + site_types;}
		}
		
		
		
	}
	int change_fish(float fish_number, sites site)
	{
		int nb_change;
		if fish_number < 0 
		{
//			ask site {fish_equation_inside <- max(fish_equation_inside - fish_number, 0.0);}
//			if fish_number < site.fish_equation_inside 
//			{ return nb_change; }
//			else { fish_number <- fish_number - site.fish_equation_inside; }
			
			list fish_alive <- fish inside site where (each.dead = false);
			if flip(int(fish_number) - fish_number) {nb_change <- int(fish_number) - 1;} 
			else {nb_change <- int(fish_number);}
			
			loop index from: 0 to: min(-nb_change, length(fish_alive)) - 1 step: 1
			{
				ask fish_alive[index] {dead <- true;}
			}
//			ret
		}
		else
		{
			if flip(fish_number  - int(fish_number)) {nb_change <- int(fish_number) + 1;} 
			else {nb_change <- int(fish_number);}
			
			ask site
			{
					create fish number: nb_change with: 
					(location:point_inside());
			}
		}
		ask manager {do kill_species;}
//		write "changed fish: " + nb_change;
		return nb_change;
	}
	int change_boat(float boat_number, sites site)
	{

		int nb_change;
		if boat_number < 0 
		{
			list boat_alive <- boat inside site where (each.dead = false);
			
			if flip(int(boat_number) - boat_number) {nb_change <- int(boat_number) - 1;} 
			else {nb_change <- int(boat_number);}
			loop index from: 0 to: min(-nb_change, length(boat_alive)) - 1 step: 1
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
					(location: point_inside());
			}
		}
		ask manager {do kill_species;}
		return float(nb_change);
	}

}



species sites
{
	list<sites> neighbors8;
	list<sites> neighbors9;


//
//	point center;
//	float w;
//	float h;
	species site_type_grid
	{
		float my_size <- map_height/100/2 * 0.8;
		int index_in_site <- int(self);
		string site_type;
//		aspect base
//		{
//			switch site_type
//			{
//				match "no fishing" { draw image_file(option_image_map["no fishing"]) size: my_size;}
////				match "no fishing" { draw circle(1/100 * map_height) color: #red;}
//				match "no fish" { draw image_file(option_image_map["no fish"]) size: my_size; }
////				default {draw image_file(option_image_map["no fish"]) size: my_size;}
//			}
//		}
		init
		{
			self.shape <- mytype_list_geometry[int(self)];
		}
	}
	action update_site_options
	{
//		write #user_location;
//		write "number of member: " + length(members as list<site_type_grid>);
		ask members as list<site_type_grid>
		{
//////			int a <-self.index_in_site;
			site_type <- index_in_site < length(site_types) ? site_types[index_in_site] : "";
			if site_type != "" {write site_type +"location: " + self.location;}
			
		}
		viable_sites_fish <- neighbors9 where (each.no_fish = false) ;
		viable_sites_boat <- neighbors9 where (each.no_fishing = false) union [self];
	}

	action update_stats
	{
		fish_inside <- fish_equation_inside + length(fish inside self);
	}
	
	action update_visual
	{
		color_value <- fish_inside/ site_capacity/3 + 0.5;
		color <- hsb(color_value, 1.0, 1.0) ;
	}
	action update
	{
		do update_stats;
		do update_site_options;
		do update_visual;
	}
//	geometry myshape;
	list<geometry> mytype_list_geometry;
	aspect base
	{
		draw shape wireframe: true border: #red;
		draw shape color: color;
	}
	aspect show_type
	{
		loop mb over: members as list<site_type_grid>
		{
			switch mb.site_type
			{
				match "no fishing" { draw image_file(option_image_map["no fishing"]) size: mb.my_size at: mb.location;}
//				match "no fishing" { draw circle(1/100 * map_height) color: #red;}
				match "no fish" { draw image_file(option_image_map["no fish"]) size: mb.my_size at: mb.location; }
//				default {draw image_file(option_image_map["no fish"]) size: mb.my_size;}
			}
		}
	}
	float site_capacity <- 500.0;
	float reproduce <- 0.0;
	float harvest <- 0.0;
//	init
//	{
//		create
//	}
	bool no_fish update: "no fish" in site_types;
	bool no_fishing update: "no fishing" in site_types;
	
// Interface	
	int fish_agent_inside update: length(fish inside self);
	float fish_equation_inside <- 0.0;
	float fish_inside update: fish_agent_inside + fish_equation_inside;
	
//	rgb color <- #white ;
	list<string> site_types <- [];
	
	float color_value <- fish_inside/ site_capacity/3 + 0.5 update: fish_inside/ site_capacity/3 + 0.5;
	rgb color <- hsb(color_value, 1.0, 1.0) update: hsb(color_value, 1.0, 1.0) ;
	
	
	init
	{
//		self.shape <- marine[0].sites_list[int(self)];
		mytype_list_geometry <- to_rectangles(self.shape, {self.shape.width/3 -2e-10, self.shape.height/3-2e-10});
//		self.shape <- myshape;
		//work around:
		create site_type_grid number: length(mytype_list_geometry);
		
		
	}
	

	aspect show_fish_inside
	{
//		draw string(fish_inside) size: map_height/100/9/4 at: self.location color: #black;
		draw string(int(self)) color: #black;
	}
	
	action reproduce_by_site
	{
		reproduce <- fish_inside * reproduce_rate * (1- fish_inside / site_capacity);
		ask world { do change_fish(myself.reproduce, myself); }
	}
	action harvest_by_site
	{
		harvest <- fishing_effort * length(boat inside self) * fish_inside;
		ask world { yield_all <- yield_all + change_fish(-myself.harvest, myself); }
		

	}


	action point_inside
	{
		return any_location_in(shape);
	}
	
	reflex temp_repr_harvest
	{
		do reproduce_by_site;
		do harvest_by_site;
	}
// Behavior

	list<sites> viable_sites_fish update: neighbors9 where (each.no_fish = false) union [self];
	list<sites> viable_sites_boat update: neighbors9 where (each.no_fishing = false) union [self];
	reflex fish_move
	{
		if empty(viable_sites_fish)
		{
			ask fish inside self
			{dead <- true; }		
		}
		else
		{
			ask fish inside self
			{ do goto target: one_of(myself.neighbors9).point_inside(); }			
		}
	}
	reflex boat_move
	{
		if empty(viable_sites_boat)
		{
			ask boat inside self 
			{dead <- true; }
		}
		else
		{
			ask boat inside self
			{ do goto target: one_of(myself.neighbors9).point_inside(); }			
		}
	}
	
// Skill
	action agent_to_equation
	{
		fish_equation_inside <- fish_inside;
		fish_agent_inside <- 0;
		ask fish inside self {dead <- true;}
	}
	action equation_to_agent
	{
		fish_agent_inside <- int(fish_inside);
		fish_equation_inside <- 0.0;
		ask world{ do change_fish(myself.fish_inside, myself); }
	}

}




grid site_options width: 4 height: 4
{

	int id <- int(self);
	string id_string <- option_image_map.keys[id];
	rgb bord_col<-#black;
	aspect normal {
		draw rectangle(shape.width * 0.8,shape.height * 0.8).contour + (shape.height * 0.01) color: bord_col;
		draw  image_file(option_image_map[id_string]) size:{shape.width * 0.5, shape.height * 0.5} ;
	}
	
	
	

}

species boat skills: [moving]
{
//general 
	bool dead <- false;
	init
	{
		speed <- 20 /100/100 * map_height ;
	}
	
	aspect base
	{
		draw circle(7/100/100 * map_height) color: #yellow;
	}
	aspect fancy
	{
		draw image_file(option_image_map["make boat"]) size: 10/100/100 * map_height;
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

species fish skills: [moving]
{
//	sites my_site;

// general
	bool dead <- false;
	init
	{
		speed <- 5.0/100/100 *map_height;	
	}
	
	aspect base
	{
		draw circle(2/100/100  *map_height) color: #black;
	}
	
}

species marine
{
		list<geometry> sites_list;
	init
	{
		float threshold <- remove_threshold* map_width/ 50* map_height/50;
		sites_list <- (to_rectangles(self.shape, {map_width/ 50, map_height/50}) where (each.area > threshold) );
		create sites number: length(sites_list); 
		ask sites
		{
			shape <- myself.sites_list[int(self)];
		}
	}
				aspect base {
		draw shape color: #blue; 
//		draw circle(2) color: #red;
	}
}

species boundary
{

			aspect base {
		draw shape color: #black; 
//		draw circle(2) color: #red;
	}
}
species docks
{

		float aspect_scale <- 10.0;
		aspect base {
			
		draw shape color: #red;// size: self.shape.width*aspect_scale;// height:  self.shape.height*aspect_scale;
		draw circle(0.5/100 *map_height ) color: #red;
	}
}


experiment Grid_interact type: gui {
	output {
//			layout horizontal([0.0::7285,1::2715]) tabs:true;
			
		display "map" type: java2D {
//			grid site_type_grid border: #black;
//			grid sites border: #black;
//			species sites aspect: default;
//			event mouse_down action: update_site_options;
			event mouse_down action: site_management;
			

//			grid site_type_grid border: #black;
			
			species boundary aspect: base;
			species docks aspect: base;
			species marine aspect: base;
			species sites aspect: base;
			species fish aspect: base;
			species boat aspect: fancy;
			
			species sites aspect: show_fish_inside;
//			species site_type_grid aspect: base;
			species sites aspect: show_type;
		}
		//display the action buttons
		display action_buton background:#black name:"Tools panel"  	{
			species site_options aspect:normal ;
			event mouse_down action:activate_act;
		}
		
					display "yield" {
				chart "yield" type: series size: {1,0.5} position: {0.0, 0.0} {
					data "Number of fish catched" value: yield_vn color: #red;
				}
//				chart "China yield" type: series size: {1,0.5} position: {0, 0.5} {
//					data "Number of fish catched" value: yield_cn color: #red;
//				}
			}	

	}
}

/* Insert your model definition here */


/* Insert your model definition here */

