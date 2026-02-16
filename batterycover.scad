// ---------- Plate parameters ----------
plate_top_width    = 57;
plate_bottom_width = 53;
plate_height = 49;
plate_thickness = 1.5;

fillet_radius   = 4;
fillet_segments = 48;

module rounding2d(r) {
    offset(r = r) offset(delta = -r) children(0);
}

module rounded_vertical_trapezoid2d(w_top, w_bot, h, r, fn=64) {
    TL = [-w_top/2,  h/2];
    TR = [ w_top/2,  h/2];
    BR = [ w_bot/2, -h/2];
    BL = [-w_bot/2, -h/2];

    poly_pts = [ TL, TR, BR, BL ];

    rounding2d(r, $fn = fn)
        polygon(points = poly_pts);
}


// sample an arc (centered at c, radius r, from a0 to a1, n segments)
function arc_points(c, r, a0, a1, n) =
  [ for(i = [0 : n]) let(a = a0 + (a1-a0)*i/n) [ c[0] + r*cos(a), c[1] + r*sin(a) ] ];


// Assembly
union() {
  // Plate
  translate([0,0,-plate_thickness/2])
  linear_extrude(height=plate_thickness, center=false, convexity=10)
    rounded_vertical_trapezoid2d(plate_top_width, plate_bottom_width, plate_height, fillet_radius);

  // Solid hinges
  {
    translate([15,-plate_height/2,plate_thickness])
      cube([7,4,plate_thickness], true);
    translate([-15,-plate_height/2,plate_thickness])
      cube([7,4,plate_thickness], true);
  }
  
  // Spring hinge
  {
    s_z = 10;
    s_y = 6;
    s_thickness = 1.0;
    
    s_halfcircle_z = s_z-s_y/2;
    pts = concat(
      [[0,0], [s_halfcircle_z,0]],
      arc_points([s_halfcircle_z,s_y/2], s_y/2, -90, 90, 50),
      [[s_halfcircle_z,s_y], [s_halfcircle_z-3,s_y+1], [s_halfcircle_z-3,s_y], [2,s_y], [2,s_y+1], [1,s_y+1], [1,s_y], [0, s_y], [0, s_y+1], [-1.25, s_y+1], [-1.25,s_y],
       [-1.25,s_y-s_thickness], [7.5, s_y-s_thickness]],
      arc_points([s_halfcircle_z,s_y/2], s_y/2 - s_thickness, 90, -90, 50),
      [[0,s_thickness]]
    );
    translate([7.5,plate_height/2-s_thickness,plate_thickness/2])
      rotate([0,-90,0])
      linear_extrude(height = 15)
      polygon(points = pts);
  }
}

