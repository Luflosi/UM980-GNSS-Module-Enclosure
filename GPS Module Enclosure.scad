include <StudModules.scad>

$fn=100;

tol=0.05; // used for CSG subtraction/addition

pcb_thickness=1.6;
height_below_pcb=1.4; // 1.32
hole_diameter=3;
hole_radius=hole_diameter/2;
pcb_radius=1.5+hole_radius;

inside_hole_width=17;
inside_hole_length=28;
center_hole_width=inside_hole_width + hole_diameter;
center_hole_length=inside_hole_length + hole_diameter;
gps_height=13;
//gps_width=26; // 25.75
//gps_length=37; // 36.5
gps_width=center_hole_width + (pcb_radius*2);
gps_length=center_hole_length + (pcb_radius*2);

usb_height=3.25;
usb_width=8.93;
usb_length=7.38;
usb_radius=usb_height/2;
usb_center_width=usb_width-usb_height;
usb_overhang=1.45;
usb_offset=0.5;
usb_hole_gap=0.3;
usb_big_hole_radius=usb_radius + 2;
usb_big_hole_offset=0.8;

enclosure_thickness=2.5;
enclosure_gap_to_pcb=1;
enclosure_radius_inner=pcb_radius+enclosure_gap_to_pcb;
enclosure_radius_outer=enclosure_radius_inner+enclosure_thickness;
antenna_diameter=5.2;
antenna_radius=antenna_diameter/2;
antenna_clearance=3; // space around the antenna connector

enclosure_inside_height_down=enclosure_gap_to_pcb + height_below_pcb;
enclosure_inside_height_up=pcb_thickness + usb_hole_gap + usb_height + usb_hole_gap + antenna_clearance + antenna_diameter + antenna_clearance;
enclosure_inside_height= enclosure_inside_height_up + enclosure_inside_height_down;




module flat_usb(r = usb_radius) {
    for(i=[-1,1])
        translate([i*usb_center_width/2, 0, 0])
            circle(r = r);
}
module usb(r = usb_radius) {
    rotate(90, v = [1, 0, 0])
        linear_extrude(height = usb_length, center = true)
            hull() {
                flat_usb(r);
            }
}

module rounded_rectangle_centered(radius) {
    hull() {
        for(i=[-1,1])
            for(j=[-1,1])
                translate([i*center_hole_width/2,j*center_hole_length/2,0])
                    circle(radius);
    }
}

module flat_pcb() {
    rounded_rectangle_centered(pcb_radius);
}

module pcb_no_holes() {
    translate([0,0,pcb_thickness/2])
        linear_extrude(height = pcb_thickness, center = true)
            flat_pcb();
}

module pcb() {
    difference() {
        pcb_no_holes();
        for(i=[-1,1])
            for(j=[-1,1])
                translate([i*center_hole_width/2,j*center_hole_length/2,0])
                    cylinder(h = gps_height + tol, r = hole_radius, center=true);
    }
}

module board() {
    translate([0,0,(gps_height/2)-height_below_pcb])
        cube([10, 20, gps_height], center = true);
    pcb();
    translate([-usb_offset,-(gps_length/2)+(usb_length/2)-usb_overhang,pcb_thickness+(usb_height/2)])
        usb();
}

module enclosure_flat_inner() {
    rounded_rectangle_centered(enclosure_radius_inner);
}
module enclosure_flat_outer() {
    rounded_rectangle_centered(enclosure_radius_outer);
}
module enclosure_inner() {
    translate([0,0,-(height_below_pcb + enclosure_gap_to_pcb)])
        linear_extrude(height = enclosure_inside_height /*+ enclosure_gap_to_pcb*2*/)
            rounded_rectangle_centered(enclosure_radius_inner);
}
module enclosure_outer() {
    translate([0,0,-(height_below_pcb + enclosure_gap_to_pcb + enclosure_thickness)])
        linear_extrude(height = enclosure_inside_height + (/*enclosure_gap_to_pcb +*/ enclosure_thickness)*2)
            rounded_rectangle_centered(enclosure_radius_outer);
}

module usb_hole() {
    translate([-usb_offset,-gps_length/2,pcb_thickness+(usb_height/2)])
        usb(r = usb_radius + usb_hole_gap);
    translate([-usb_offset,-gps_length/2 - (usb_length/2 + enclosure_gap_to_pcb + usb_big_hole_offset),pcb_thickness+(usb_height/2)])
        usb(r = usb_big_hole_radius);
}
module antenna_hole() {
    translate([0,-15, pcb_thickness+usb_height+antenna_clearance+antenna_radius])
        rotate(90, v = [1, 0, 0])
            linear_extrude(height = 10)
                circle(r = antenna_radius);
}

module enclosure() {
    difference() {
        enclosure_outer();
        enclosure_inner();
        usb_hole();
        antenna_hole();
    };
    for(i=[-1,1])
        for(j=[-1,1])
            m3_short_stud(i*center_hole_width/2,j*center_hole_length/2,0,off=-4.63);
}

//color([0.5,0.5,0.5,0.5]) board();
difference() {
/*color([0.5,0.5,0,0.5])*/ enclosure();
//translate([0,-30,-10]) cube([100,100,100]); // Cut off side
translate([-30,-30,enclosure_inside_height - enclosure_inside_height_down - tol - 14]) cube([100,100,100]); // Cut off top
//translate([-30,-gps_length/2,-30]) cube([100,100,100]); // Only leave ports
}