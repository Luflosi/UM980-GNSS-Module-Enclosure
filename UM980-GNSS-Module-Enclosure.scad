// SPDX-FileCopyrightText: 2026 Luflosi <UM980-GNSS-Module-Enclosure@luflosi.de>
// SPDX-License-Identifier: GPL-3.0-only

$fn = 100;

epsilon = 0.05; // used for CSG subtraction/addition

tolerance = 0.2;

pcb_thickness = 1.6;
height_below_pcb = 1.4; // 1.32
hole_diameter = 3;
hole_radius = hole_diameter / 2;
pcb_radius = 1.5 + hole_radius;

inside_hole_width = 17;
inside_hole_length = 28;
center_hole_width = inside_hole_width + hole_diameter;
center_hole_length = inside_hole_length + hole_diameter;
gps_height = 13;
//gps_width=26; // 25.75
//gps_length=37; // 36.5
gps_width = center_hole_width + (pcb_radius * 2);
gps_length = center_hole_length + (pcb_radius * 2);

usb_height = 3.25;
usb_width = 8.93;
usb_length = 7.38;
usb_radius = usb_height / 2;
usb_center_width = usb_width - usb_height;
usb_overhang = 1.45;
usb_offset = 0.5;
usb_hole_gap = 0.3;
usb_big_hole_radius = usb_radius + 2;
usb_big_hole_offset = 0.9;

enclosure_thickness = 2.5;
enclosure_gap_to_pcb = 1;
enclosure_radius_inner = pcb_radius + enclosure_gap_to_pcb;
enclosure_radius_outer = enclosure_radius_inner + enclosure_thickness;
antenna_diameter = 5.2;
antenna_radius = antenna_diameter / 2;
antenna_hole_gap = 0.2;
antenna_clearance = 3; // Space around the antenna connector not occupied by the USB-C connector or the enclosure
antenna_hex_diameter = antenna_diameter + 1; // TODO: actually measure
antenna_hex_radius = antenna_hex_diameter / 2;
antenna_hex_length = 5;
antenna_big_hole_offset = 0.5;

enclosure_inside_height_down = enclosure_gap_to_pcb + height_below_pcb;
enclosure_inside_height_up = pcb_thickness + usb_hole_gap + usb_height + usb_hole_gap + antenna_clearance + antenna_diameter + antenna_clearance;
enclosure_inside_height = enclosure_inside_height_up + enclosure_inside_height_down;

clamp_radius = 1;
clamp_offset = center_hole_width / 2 + enclosure_radius_inner - clamp_radius / 2;
clamp_length = 5;
clamp_height = 14;

lid_display_offset = 50;
lid_ridge_step_height = 2;
lid_clamp_offset = 0.2 * clamp_radius;

module flat_usb(r = usb_radius) {
	for (i = [-1, 1])
		translate([i * usb_center_width / 2, 0, 0])
			circle(r=r);
}
module usb(r = usb_radius) {
	rotate(90, v=[1, 0, 0])
		linear_extrude(height=usb_length, center=true)
			hull() {
				flat_usb(r);
			}
}

module rounded_rectangle_centered(radius) {
	hull() {
		for (i = [-1, 1])
			for (j = [-1, 1])
				translate([i * center_hole_width / 2, j * center_hole_length / 2, 0])
					circle(radius);
	}
}

module flat_pcb() {
	rounded_rectangle_centered(pcb_radius);
}

module pcb_no_holes() {
	translate([0, 0, pcb_thickness / 2])
		linear_extrude(height=pcb_thickness, center=true)
			flat_pcb();
}

module pcb() {
	difference() {
		pcb_no_holes();
		for (i = [-1, 1])
			for (j = [-1, 1])
				translate([i * center_hole_width / 2, j * center_hole_length / 2, 0])
					cylinder(h=gps_height + epsilon, r=hole_radius, center=true);
	}
}

module board() {
	translate([0, 0, (gps_height / 2) - height_below_pcb])
		cube([10, 20, gps_height], center=true);
	pcb();
	translate([-usb_offset, -(gps_length / 2) + (usb_length / 2) - usb_overhang, pcb_thickness + (usb_height / 2)])
		usb();
}

module enclosure_flat_inner() {
	rounded_rectangle_centered(enclosure_radius_inner);
}
module enclosure_flat_outer() {
	rounded_rectangle_centered(enclosure_radius_outer);
}
module enclosure_inner() {
	translate([0, 0, -(height_below_pcb + enclosure_gap_to_pcb)])
		linear_extrude(height=enclosure_inside_height /*+ enclosure_gap_to_pcb*2*/)
			rounded_rectangle_centered(enclosure_radius_inner);
}
module enclosure_outer() {
	translate([0, 0, -(height_below_pcb + enclosure_gap_to_pcb + enclosure_thickness)])
		linear_extrude(height=enclosure_inside_height + ( /*enclosure_gap_to_pcb +*/ enclosure_thickness) * 2)
			rounded_rectangle_centered(enclosure_radius_outer);
}
module enclosure_shell() {
	difference() {
		enclosure_outer();
		enclosure_inner();
	}
}
module usb_hole() {
	translate([-usb_offset, -gps_length / 2, pcb_thickness + (usb_height / 2)])
		usb(r=usb_radius + usb_hole_gap);
	translate([-usb_offset, -gps_length / 2 - (usb_length / 2 + enclosure_gap_to_pcb + usb_big_hole_offset), pcb_thickness + (usb_height / 2)])
		usb(r=usb_big_hole_radius);
}
module antenna_hex_hole() {
	hex_radius = (antenna_hex_radius + antenna_hole_gap) / cos(180 / 6);
	rotate(90, v=[1, 0, 0])
		rotate(30, v=[0, 0, 1])
			linear_extrude(height=antenna_hex_length)
				circle(r=hex_radius, $fn=6);
}
module antenna_hole() {
	translate([0, -(gps_length / 2 + enclosure_gap_to_pcb + antenna_big_hole_offset), 0]) {
		translate([0, epsilon, pcb_thickness + usb_height + antenna_clearance + antenna_radius])
			rotate(90, v=[1, 0, 0])
				linear_extrude(height=10)
					circle(r=antenna_radius + antenna_hole_gap);
		translate([0, antenna_hex_length, pcb_thickness + usb_height + antenna_clearance + antenna_radius])
			antenna_hex_hole();
	}
}
// m3 short stud
module stud_outer(x, y, off = -4.63) {
	maxid = 5.59; //Maximum Insert Diameter
	ted = 5.16; //Tapered End Diameter
	oil = 3.81; //Overal Insert Length
	rmwt = maxid * 0.53; //Recommended Min Wall Thickness
	ahd = 0.76; //Added Hole Depth for Blind Holes
	cham = 0.5; //Chamfer at top of stud
	stud_top = maxid + (rmwt * 2); //Top of Stud Diameter
	stud_bot = stud_top + (cham * 2); //Bottom of Stud Diameter
	st_h = oil + ahd; // Overall stud height
	st_base = st_h - cham; //Height of Stud to chamfer

	union() {
		translate([x, y, off]) cylinder(d=stud_bot, st_base);
		translate([x, y, st_base + off]) cylinder(d1=stud_bot, d2=stud_top, cham);
	}
}
module stud_inner(x, y, off = -4.63) {
	oil = 3.81; //Overal Insert Length
	ophs = 5.05; //Optimum Pilot Hole Size
	oshd = 5.23; //Optimum Surface Hole Diameter
	ahd = 0.76; //Added Hole Depth for Blind Holes
	th = 0.64; //Height of 8° Taper
	st_h = oil + ahd; // Overall stud height

	#union() {
		translate([x, y, off]) cylinder(d=ophs, oil + ahd);
		translate([x, y, st_h - th + off]) cylinder(d1=ophs, d2=oshd, th);
	}
}
module antenna_solder_cutout() {
	cube_size = 10;
	offset = 2;
	translate([center_hole_width / 2 - cube_size - offset, -center_hole_length / 2 + offset, -cube_size]) cube(cube_size);
}
module studs_outer() {
	for (i = [-1, 1])
		stud_outer(i * center_hole_width / 2, center_hole_length / 2);
	difference() {
		stud_outer(center_hole_width / 2, -1 * center_hole_length / 2);
		antenna_solder_cutout();
	}
	stud_outer(-1 * center_hole_width / 2, -1 * center_hole_length / 2);
}
module studs_inner() {
	for (i = [-1, 1])
		for (j = [-1, 1])
			stud_inner(i * center_hole_width / 2, j * center_hole_length / 2);
}

module clamps() {
	for (i = [-1, 1])
		hull() {
			for (j = [-1, 1])
				translate([i * clamp_offset, j * clamp_length / 2, clamp_height])
					sphere(r=clamp_radius);
		}
	;
}

module enclosure() {
	difference() {
		union() {
			enclosure_shell();
			studs_outer();
		}
		usb_hole();
		antenna_hole();
		studs_inner();
		clamps();
	}
	;
}

module lid_top() {
	translate([0, 0, enclosure_inside_height - height_below_pcb - enclosure_gap_to_pcb])
		linear_extrude(height=enclosure_thickness)
			rounded_rectangle_centered(enclosure_radius_outer);
}
module lid_clamp_holders() {
	offset = clamp_offset;
	tab_width = clamp_radius;
	for (i = [-1, 1])
		translate([i * (offset - tab_width / 2 - lid_clamp_offset), 0, enclosure_inside_height - height_below_pcb - enclosure_gap_to_pcb])
			cube([tab_width, clamp_length, 5], center=true);
}
module lid_ridge() {
	translate([0, 0, -(height_below_pcb + enclosure_gap_to_pcb - enclosure_inside_height + lid_ridge_step_height)])
		linear_extrude(height=lid_ridge_step_height + epsilon)
			rounded_rectangle_centered(enclosure_radius_inner - tolerance);
}

module lid_clamps() {
	for (i = [-1, 1])
		hull() {
			for (j = [-1, 1])
				translate([i * clamp_offset - lid_clamp_offset, j * clamp_length / 2, clamp_height])
					sphere(r=clamp_radius);
		}
	;
}
module lid() {
	lid_top();
	lid_clamps();
	lid_clamp_holders();
	lid_ridge();
}

module cut_enclosure() {
	//color([0.5,0.5,0.5,0.5]) board();
	difference() {
		/*color([0.5,0.5,0,0.5])*/ enclosure();
		translate([-30, -30, enclosure_inside_height - enclosure_inside_height_down - epsilon /*- 14*/]) cube(100); // Cut off top
	}
}

enable_lid = true;
enable_enclosure = true;
module everything() {
	if (enable_enclosure)
		cut_enclosure();

	if (enable_lid)
		translate([0, 0, lid_display_offset])
			lid();
}

difference() {
	everything();
	//translate([0,-30,-10]) cube([100,100,100]); // Cut off side
	//translate([-30,0,-10]) cube([50,50,50]); // Cut off other side
}
